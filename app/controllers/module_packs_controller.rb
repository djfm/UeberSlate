require 'fileutils'
require 'jobs/import_module_job.rb'

class ModulePacksController < ApplicationController
  # GET /module_packs
  # GET /module_packs.json
  def index
    @module_packs = ModulePack.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @module_packs }
    end
  end

  # GET /module_packs/1
  # GET /module_packs/1.json
  def show
    @module_pack = ModulePack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @module_pack }
    end
  end

  # GET /module_packs/new
  # GET /module_packs/new.json
  def new
    @module_pack = ModulePack.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @module_pack }
    end
  end

  # GET /module_packs/1/edit
  def edit
    @module_pack = ModulePack.find(params[:id])
  end

  # POST /module_packs
  # POST /module_packs.json
  def create
    @module_pack = ModulePack.new(params[:module_pack])

    respond_to do |format|
      if @module_pack.save
        format.html { redirect_to @module_pack, notice: 'Module pack was successfully created.' }
        format.json { render json: @module_pack, status: :created, location: @module_pack }
      else
        format.html { render action: "new" }
        format.json { render json: @module_pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /module_packs/1
  # PUT /module_packs/1.json
  def update
    @module_pack = ModulePack.find(params[:id])

    respond_to do |format|
      if @module_pack.update_attributes(params[:module_pack])
        format.html { redirect_to @module_pack, notice: 'Module pack was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @module_pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /module_packs/1
  # DELETE /module_packs/1.json
  def destroy
    @module_pack = ModulePack.find(params[:id])
    @module_pack.destroy

    respond_to do |format|
      format.html { redirect_to module_packs_url }
      format.json { head :no_content }
    end
  end
  
  def import_module
    
    if ma = params[:module_archive]
      FileUtils.mv ma.tempfile.path, (path="upload/modules/#{ma.original_filename}")
      flash[:notice] = "Processing! Just wait man!"
      Resque.enqueue ImportModuleJob, current_user.id, path
    else
      flash[:notice] = "No module selected!"
    end
    
    redirect_to module_packs_path
  end
  
end
