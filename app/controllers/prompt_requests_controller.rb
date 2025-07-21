class PromptRequestsController < ApplicationController
  before_action :set_prompt_request, only: %i[ show edit update destroy ]

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
    # binding.pry
    @prompt_request = PromptRequest.new(prompt_request_params)

    prefixed_prompt = if @prompt_request.action_type.present?
      "#{@prompt_request.action_type}: #{@prompt_request.input_text}"
    else
      @prompt_request.input_text
    end
    @prompt_request.output_text = generate_output_text(prefixed_prompt)
    @prompt_request.status = I18n.t('prompt_requests.status.pending')
    @prompt_request.input_text = @prompt_request.input_text.strip if @prompt_request.input_text.present?
    @prompt_request.output_text = @prompt_request.output_text.strip if @prompt_request.output_text.present?
    error_message = I18n.t('prompt_requests.errors.processing_request')
    @prompt_request.status = I18n.t('prompt_requests.status.completed') if @prompt_request.output_text.present? && @prompt_request.output_text != error_message
    @prompt_request.status = I18n.t('prompt_requests.status.failed') if @prompt_request.output_text.blank? || @prompt_request.output_text == error_message

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
      format.html { redirect_to prompt_requests_path, status: :see_other, notice: I18n.t('prompt_requests.notices.destroyed') }
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
      api_response = ApiClient.generate(prompt)
      if api_response.is_a?(Hash) && api_response['response']
        api_response['response'].to_s
      elsif api_response.is_a?(String)
        api_response.to_s
      else
        api_response['error'] || I18n.t('prompt_requests.errors.processing_request')
      end
    end
end
