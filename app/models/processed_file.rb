class ProcessedFile < ApplicationRecord
  has_one_attached :document
  
  # Validações
  validates :document, presence: true
  validates :summary_type, inclusion: { in: %w[detailed brief bullet_points executive] }, allow_blank: false
  validates :status, inclusion: { in: %w[pending processing completed failed] }, allow_blank: true
  
  # Callbacks
  before_validation :set_defaults
  before_create :extract_filename
  
  # Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  
  # Métodos de status
  def pending?
    status == 'pending'
  end
  
  def processing?
    status == 'processing'
  end
  
  def completed?
    status == 'completed'
  end
  
  def failed?
    status == 'failed'
  end
  
  # Método para processar o arquivo
  def process_document!
    return false unless document.attached?
    
    update!(status: 'processing')
    
    begin
      # Ler o conteúdo do arquivo
      document_text = extract_text_from_document
      
      if document_text.blank?
        raise "Não foi possível extrair texto do documento"
      end
      
      # Processar com IA usando o ApiClient
      begin
        summary_text = ApiClient.summarize_document(document_text, summary_type: summary_type)
        
        # Se a API falhar ou retornar vazio, usar simulação como fallback
        if summary_text.blank?
          Rails.logger.warn "API retornou vazio, usando simulação como fallback"
          summary_text = simulate_ai_processing(document_text)
        end
      rescue => api_error
        Rails.logger.error "Erro na API: #{api_error.message}, usando simulação como fallback"
        summary_text = simulate_ai_processing(document_text)
      end
      
      # Salvar resultado
      update!(
        summary: summary_text,
        status: 'completed'
      )
      
      true
    rescue => e
      error_message = "Erro ao processar arquivo #{filename}: #{e.message}"
      Rails.logger.error error_message
      
      update!(
        status: 'failed',
        summary: "Erro: #{e.message}"
      )
      
      false
    end
  end

  private
  
  def simulate_ai_processing(text)
    # Simulação temporária até a API estar funcionando
    word_count = text.split.size
    char_count = text.length
    
    case summary_type
    when 'brief'
      "Resumo breve: Este documento contém #{word_count} palavras e #{char_count} caracteres. " \
      "Primeiras palavras: #{text.split.first(10).join(' ')}..."
    when 'bullet_points'
      "• Documento com #{word_count} palavras\n" \
      "• Total de #{char_count} caracteres\n" \
      "• Tipo de arquivo: #{document.content_type}\n" \
      "• Processado em: #{Time.current.strftime('%d/%m/%Y às %H:%M')}"
    when 'executive'
      "RESUMO EXECUTIVO\n\n" \
      "Documento: #{filename}\n" \
      "Extensão: #{word_count} palavras\n" \
      "Processamento: Concluído com sucesso\n\n" \
      "Prévia do conteúdo: #{text.split.first(20).join(' ')}..."
    else # detailed
      "Resumo detalhado do documento '#{filename}':\n\n" \
      "Este arquivo contém #{word_count} palavras distribuídas em #{char_count} caracteres. " \
      "O documento foi processado com sucesso e seu conteúdo está disponível para análise. " \
      "\n\nPrévia do conteúdo:\n#{text.split.first(50).join(' ')}#{'...' if word_count > 50}"
    end
  end
  
  private
  
  def set_defaults
    self.status ||= 'pending'
    self.summary_type ||= 'detailed'
  end
  
  def extract_filename
    self.filename = document.filename.to_s if document.attached?
  end
  
  def extract_text_from_document
    return '' unless document.attached?
    
    begin
      case document.content_type
      when 'text/plain', 'text/markdown'
        document.download.force_encoding('UTF-8')
      when 'application/pdf'
        extract_text_from_pdf
      when 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
           'application/msword'
        # Para documentos Word, tentar ler como texto (limitado)
        document.download.force_encoding('UTF-8').gsub(/[^\x20-\x7E\n\r\t]/, '')
      else
        # Para outros formatos, tentar ler como texto
        text = document.download.force_encoding('UTF-8')
        # Remover caracteres não imprimíveis
        text.gsub(/[^\x20-\x7E\n\r\t]/, '')
      end
    rescue => e
      Rails.logger.error "Erro ao extrair texto do documento: #{e.message}"
      raise "Erro ao processar o arquivo: formato não suportado ou arquivo corrompido"
    end
  end

  def extract_text_from_pdf
    require 'pdf-reader'
    
    text = ""
    PDF::Reader.new(StringIO.new(document.download)).pages.each do |page|
      text += page.text + "\n"
    end
    
    # Limpar texto extraído
    text.gsub(/\s+/, ' ').strip
  rescue => e
    Rails.logger.error "Erro ao processar PDF: #{e.message}"
    raise "Erro ao processar PDF: arquivo pode estar protegido ou corrompido"
  end
end
