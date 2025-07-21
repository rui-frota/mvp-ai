require 'net/http'
require 'json'

class ApiClient
  OLLAMA_URL = 'http://localhost:11434/api/generate'

  def self.generate(prompt, model: 'llama3.2')
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

  def self.summarize_document(document_text, model: 'llama3.2', summary_type: 'detailed')
    prompt_templates = {
      'brief' => "Faça um resumo breve (2-3 parágrafos) do seguinte documento:\n\n#{document_text}",
      'detailed' => "Faça um resumo detalhado do seguinte documento, incluindo os pontos principais e conclusões:\n\n#{document_text}",
      'bullet_points' => "Extraia os pontos principais do seguinte documento em formato de lista:\n\n#{document_text}",
      'executive' => "Faça um resumo executivo profissional do seguinte documento:\n\n#{document_text}"
    }
    
    prompt = prompt_templates[summary_type] || prompt_templates['detailed']
    generate(prompt, model: model)
  end

  # Método para processar arquivos de texto
  def self.summarize_file(file_path, model: 'llama3.2', summary_type: 'detailed')
    unless File.exist?(file_path)
      raise "Arquivo não encontrado: #{file_path}"
    end

    # Verificar o tamanho do arquivo
    file_size = File.size(file_path)
    if file_size > 1_000_000 # 1MB
      puts "Aviso: Arquivo grande (#{file_size} bytes). Considere dividir em partes menores."
    end

    document_text = File.read(file_path, encoding: 'UTF-8')
    summarize_document(document_text, model: model, summary_type: summary_type)
  rescue Encoding::InvalidByteSequenceError
    # Tentar outras codificações
    document_text = File.read(file_path, encoding: 'ISO-8859-1')
    summarize_document(document_text, model: model, summary_type: summary_type)
  end

  # Método para processar documentos grandes em chunks
  def self.summarize_large_document(document_text, model: 'llama3.2', chunk_size: 4000)
    if document_text.length <= chunk_size
      return summarize_document(document_text, model: model)
    end

    # Dividir o documento em chunks
    chunks = document_text.scan(/.{1,#{chunk_size}}/m)
    chunk_summaries = []

    chunks.each_with_index do |chunk, index|
      puts "Processando chunk #{index + 1}/#{chunks.length}..."
      summary = summarize_document(chunk, model: model, summary_type: 'brief')
      chunk_summaries << summary
    end

    # Resumir os resumos
    combined_summaries = chunk_summaries.join("\n\n")
    final_prompt = "Faça um resumo final consolidado dos seguintes resumos parciais:\n\n#{combined_summaries}"
    generate(final_prompt, model: model)
  end

  # Método para extrair informações específicas
  def self.extract_information(document_text, question, model: 'llama3.2')
    prompt = "Com base no seguinte documento, responda à pergunta: #{question}\n\nDocumento:\n#{document_text}"
    generate(prompt, model: model)
  end
end