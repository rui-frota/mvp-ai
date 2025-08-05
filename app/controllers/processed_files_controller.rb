class ProcessedFilesController < ApplicationController
  before_action :set_processed_file, only: %i[ show edit update destroy ]

  # GET /processed_files or /processed_files.json
  def index
    @processed_files = ProcessedFile.all
  end

  # GET /processed_files/1 or /processed_files/1.json
  def show
  end

  # GET /processed_files/new
  def new
    @processed_file = ProcessedFile.new
  end

  # GET /processed_files/1/edit
  def edit
  end

  # POST /processed_files or /processed_files.json
  def create
    @processed_file = ProcessedFile.new(processed_file_params)

    respond_to do |format|
      if @processed_file.save
        # Processar o arquivo em background (ou imediatamente para demo)
        if @processed_file.process_document!
          format.html { redirect_to @processed_file, notice: t('processed_files.notices.created') }
          format.json { render :show, status: :created, location: @processed_file }
        else
          format.html { redirect_to @processed_file, alert: t('processed_files.errors.processing_file') }
          format.json { render json: { error: t('processed_files.errors.processing_file') }, status: :unprocessable_entity }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @processed_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /processed_files/1 or /processed_files/1.json
  def update
    respond_to do |format|
      if @processed_file.update(processed_file_params)
        format.html { redirect_to @processed_file, notice: t('processed_files.notices.updated') }
        format.json { render :show, status: :ok, location: @processed_file }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @processed_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /processed_files/1 or /processed_files/1.json
  def destroy
    @processed_file.destroy!

    respond_to do |format|
      format.html { redirect_to processed_files_path, status: :see_other, alert: t('processed_files.notices.destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_processed_file
      @processed_file = ProcessedFile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def processed_file_params
      params.require(:processed_file).permit(:document, :action_type)
    end
end
