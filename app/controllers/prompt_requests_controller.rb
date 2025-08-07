require 'net/http'
require 'socket'

class PromptRequestsController < ApplicationController
  before_action :set_prompt_request, only: %i[ show edit update destroy ]

  # Exceção customizada para erros de conexão com IA
  class AIConnectionError < StandardError; end

  # GET /prompt_requests or /prompt_requests.json
  def index
    @prompt_requests = PromptRequest.all
  end

  # GET /prompt_requests/1 or /prompt_requests/1.json
  def show
  end

  # GET /prompt_requests/new
  def new
    @prompt_request = PromptRequest.new
  end

  # GET /prompt_requests/1/edit
  def edit
  end

  # POST /prompt_requests or /prompt_requests.json
  def create
    @prompt_request = PromptRequest.new(prompt_request_params)

    # 🛡️ GUARDRAILS: Moderação do input
    input_moderation = ContentModerationService.moderate_input(@prompt_request.input_text)
    
    unless input_moderation[:approved]
      @prompt_request.errors.add(:input_text, "Conteúdo não permitido: #{input_moderation[:reasons].join(', ')}")
      
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @prompt_request.errors, status: :unprocessable_entity }
      end
      return
    end

    prefixed_prompt = if @prompt_request.action_type.present?
      build_specific_prompt(@prompt_request.action_type, @prompt_request.input_text)
    else
      @prompt_request.input_text
    end
    
    begin
      raw_output = generate_output_text(prefixed_prompt)
      
      # 🛡️ GUARDRAILS: Moderação do output
      output_moderation = ContentModerationService.moderate_output(raw_output)
      
      @prompt_request.output_text = output_moderation[:text]
      @prompt_request.status = 'pending'
      @prompt_request.input_text = @prompt_request.input_text.strip if @prompt_request.input_text.present?
      @prompt_request.output_text = @prompt_request.output_text.strip if @prompt_request.output_text.present?
      
      error_message = I18n.t('prompt_requests.errors.processing_request')
      @prompt_request.status = 'completed' if @prompt_request.output_text.present? && @prompt_request.output_text != error_message
      @prompt_request.status = 'failed' if @prompt_request.output_text.blank? || @prompt_request.output_text == error_message
      
      # Log de moderação para auditoria
      if !output_moderation[:approved]
        Rails.logger.warn "🛡️ Output moderado - Riscos: #{output_moderation[:reasons].join(', ')} - Nível: #{output_moderation[:risk_level]}"
      end
      
    rescue AIConnectionError => e
      @prompt_request.status = 'failed'
      @prompt_request.output_text = nil
      
      respond_to do |format|
        if @prompt_request.save
          format.html { redirect_to @prompt_request, alert: e.message }
          format.json { render json: { error: e.message }, status: :service_unavailable }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @prompt_request.errors, status: :unprocessable_entity }
        end
      end
      return
    end

    respond_to do |format|
      if @prompt_request.save
        format.html { redirect_to @prompt_request, notice: I18n.t('prompt_requests.notices.created') }
        format.json { render :show, status: :created, location: @prompt_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @prompt_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prompt_requests/1 or /prompt_requests/1.json
  def update
    respond_to do |format|
      if @prompt_request.update(prompt_request_params)
        format.html { redirect_to @prompt_request, notice: I18n.t('prompt_requests.notices.updated') }
        format.json { render :show, status: :ok, location: @prompt_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @prompt_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prompt_requests/1 or /prompt_requests/1.json
  def destroy
    @prompt_request.destroy!

    respond_to do |format|
      format.html { redirect_to prompt_requests_path, status: :see_other, alert: I18n.t('prompt_requests.notices.destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prompt_request
      @prompt_request = PromptRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def prompt_request_params
      params.require(:prompt_request).permit(:input_text, :action_type, :output_text, :status)
    end

    # Method to generate output text based on the input prompt   
    def generate_output_text(prompt)
      begin
        api_response = ApiClient.generate(prompt)
        if api_response.is_a?(Hash) && api_response['response']
          api_response['response'].to_s
        elsif api_response.is_a?(String)
          api_response.to_s
        else
          api_response['error'] || I18n.t('prompt_requests.errors.processing_request')
        end
      rescue Errno::ECONNREFUSED, Net::TimeoutError, SocketError => e
        Rails.logger.error "🤖 IA desconectada: #{e.message}"
        raise AIConnectionError, I18n.t('prompt_requests.errors.ai_disconnected')
      rescue StandardError => e
        Rails.logger.error "Erro ao processar prompt: #{e.message}"
        I18n.t('prompt_requests.errors.processing_request')
      end
    end

    # Build specific prompts based on action type
    def build_specific_prompt(action_type, input_text)
      case action_type
      when 'answer'
        "Responda à seguinte pergunta de forma clara e detalhada: #{input_text}"
      when 'explain'
        "Explique de forma didática e compreensível: #{input_text}"
      when 'summarize'
        "Faça um resumo conciso e bem estruturado do seguinte texto: #{input_text}"
      when 'improve'
        "Melhore a qualidade, clareza e fluidez do seguinte texto: #{input_text}"
      when 'correct'
        "Corrija os erros gramaticais e de ortografia no seguinte texto: #{input_text}"
      when 'rewrite'
        "Reescreva o seguinte texto de uma forma mais clara e envolvente: #{input_text}"
      when 'analyze'
        "Analise detalhadamente o seguinte conteúdo e forneça insights: #{input_text}"
      when 'extract_keywords'
        "Extraia as palavras-chave principais e conceitos importantes do seguinte texto: #{input_text}"
      when 'create_outline'
        "Crie uma estrutura organizada (outline) baseada no seguinte conteúdo: #{input_text}"
      when 'bullet_points'
        "Converta o seguinte texto em uma lista de tópicos organizados: #{input_text}"
      when 'tone_formal'
        "Reescreva o seguinte texto adotando um tom formal e profissional: #{input_text}"
      when 'tone_casual'
        "Reescreva o seguinte texto adotando um tom casual e conversacional: #{input_text}"
      when 'creative_writing'
        "Use criatividade para expandir e enriquecer o seguinte texto: #{input_text}"
      when 'create_email'
        "Crie um e-mail profissional baseado nas seguintes informações: #{input_text}"
      when 'generate_ideas'
        "Gere ideias criativas e úteis relacionadas ao seguinte tópico: #{input_text}"
      when 'question_answer'
        "Crie perguntas relevantes e suas respectivas respostas sobre: #{input_text}"
      when 'code_review'
        "Revise o seguinte código e forneça sugestões de melhoria: #{input_text}"
      when 'translate_br_us'
        "Traduza o seguinte texto do português brasileiro para o inglês americano: #{input_text}"
      when 'translate_us_br'
        "Traduza o seguinte texto do inglês americano para o português brasileiro: #{input_text}"
      else
        input_text
      end
    end
end
