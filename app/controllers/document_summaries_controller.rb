class DocumentSummariesController < ApplicationController
  def new
  end

  def create
    if params[:document_file].present?
      # Upload de arquivo
      uploaded_file = params[:document_file]
      temp_path = Rails.root.join('tmp', 'uploads', uploaded_file.original_filename)
      
      # Criar diretório se não existir
      FileUtils.mkdir_p(File.dirname(temp_path))
      
      # Salvar arquivo temporariamente
      File.open(temp_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      begin
        @summary = ApiClient.summarize_file(temp_path, summary_type: params[:summary_type] || 'detailed')
        @success = true
      rescue => e
        @error = "Erro ao processar arquivo: #{e.message}"
      ensure
        # Limpar arquivo temporário
        File.delete(temp_path) if File.exist?(temp_path)
      end

    elsif params[:document_text].present?
      # Texto direto
      begin
        @summary = ApiClient.summarize_document(
          params[:document_text], 
          summary_type: params[:summary_type] || 'detailed'
        )
        @success = true
      rescue => e
        @error = "Erro ao processar texto: #{e.message}"
      end
    else
      @error = "Por favor, forneça um arquivo ou texto para resumir."
    end

    render :result
  end

  private

  def document_params
    params.permit(:document_file, :document_text, :summary_type)
  end
end
