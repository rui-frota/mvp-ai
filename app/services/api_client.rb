require 'net/http'
require 'json'

class ApiClient
  OLLAMA_URL = 'http://localhost:11434/api/generate'
  def self.generate(prompt, model: 'llama3')
    uri = URI(OLLAMA_URL)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = { model: model, prompt: prompt }.to_json

    response_text = ""
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req) do |res|
        res.body.each_line do |line|
          line = line.strip
          next if line.empty?
          line.scan(/\{.*?\}(?=\{|\z)/).each do |json_str|
            begin
              data = JSON.parse(json_str)
              response_text << data["response"].to_s if data["response"]
              break if data["done"]
            rescue JSON::ParserError
              next
            end
          end
        end
      end
    end
    response_text.strip
  end

  def self.summarize_document(document_text, model: 'llama3', action_type: 'detailed')
    prompt_templates = {
      # Tipos de Resumo
      'brief' => "Faça um resumo breve (2-3 parágrafos) do seguinte documento:\n\n#{document_text}",
      'detailed' => "Faça um resumo detalhado do seguinte documento, incluindo os pontos principais e conclusões:\n\n#{document_text}",
      'bullet_points' => "Extraia os pontos principais do seguinte documento em formato de lista:\n\n#{document_text}",
      'executive' => "Faça um resumo executivo profissional do seguinte documento:\n\n#{document_text}",
      # Tradução
      'translate_br_us' => "Traduza o seguinte documento do português brasileiro para o inglês americano:\n\n#{document_text}",
      'translate_us_br' => "Traduza o seguinte documento do inglês americano para o português brasileiro:\n\n#{document_text}",
      # Análise Avançada
      'sentiment_analysis' => "Analise o sentimento do seguinte documento:\n\n#{document_text}",
      'keyword_extraction' => "Extraia as palavras-chave principais do seguinte documento:\n\n#{document_text}",
      'theme_identification' => "Identifique os tópicos principais do seguinte documento:\n\n#{document_text}",
      'structure_analysis' => "Analise a estrutura e organização do seguinte documento:\n\n#{document_text}",
      # Processamento Específico
      'grammar_correction' => "Corrija a gramática do seguinte documento:\n\n#{document_text}",
      'text_simplification' => "Simplifique o texto do seguinte documento:\n\n#{document_text}",
      'standard_formatting' => "Formate o seguinte documento seguindo padrões:\n\n#{document_text}",
      # Relatórios
      'full_report' => "Faça um relatório completo do seguinte documento:\n\n#{document_text}",
      'executive_report' => "Faça um relatório executivo do seguinte documento:\n\n#{document_text}",
      'comparative_analysis' => "Faça uma análise comparativa dos elementos do seguinte documento:\n\n#{document_text}",
      'quality_metrics' => "Analise as métricas de qualidade do seguinte documento:\n\n#{document_text}"
    }
    
    prompt = prompt_templates[action_type] || prompt_templates['detailed']
    generate(prompt, model: model)
  end

  # Método para processar arquivos de texto
  def self.summarize_file(file_path, model: 'llama3', action_type: 'detailed')
    unless File.exist?(file_path)
      raise "Arquivo não encontrado: #{file_path}"
    end

    # Verificar o tamanho do arquivo
    file_size = File.size(file_path)
    if file_size > 1_000_000 # 1MB
      puts "Aviso: Arquivo grande (#{file_size} bytes). Considere dividir em partes menores."
    end

    document_text = File.read(file_path, encoding: 'UTF-8')
    summarize_document(document_text, model: model, action_type: action_type)
  rescue Encoding::InvalidByteSequenceError
    # Tentar outras codificações
    document_text = File.read(file_path, encoding: 'ISO-8859-1')
    summarize_document(document_text, model: model, action_type: action_type)
  end

  # Método para processar documentos grandes em chunks
  def self.summarize_large_document(document_text, model: 'llama3', chunk_size: 4000)
    if document_text.length <= chunk_size
      return summarize_document(document_text, model: model)
    end

    # Dividir o documento em chunks
    chunks = document_text.scan(/.{1,#{chunk_size}}/m)
    chunk_summaries = []

    chunks.each_with_index do |chunk, index|
      puts "Processando chunk #{index + 1}/#{chunks.length}..."
      summary = summarize_document(chunk, model: model, action_type: 'brief')
      chunk_summaries << summary
    end

    # Resumir os resumos
    combined_summaries = chunk_summaries.join("\n\n")
    final_prompt = "Faça um resumo final consolidado dos seguintes resumos parciais:\n\n#{combined_summaries}"
    generate(final_prompt, model: model)
  end

  # Método para extrair informações específicas
  def self.extract_information(document_text, question, model: 'llama3')
    prompt = "Com base no seguinte documento, responda à pergunta: #{question}\n\nDocumento:\n#{document_text}"
    generate(prompt, model: model)
  end
end