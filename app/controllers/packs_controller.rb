require 'adapters/messages_adapter.rb'
require 'jobs/messages_import_job.rb'
require 'jobs/pack_build_job.rb'
require 'jobs/pack_grind_job.rb'

class PacksController < ApplicationController
  
  before_filter :prepare_project_list, :only => [:new, :edit, :create, :update] 
  after_filter :add_messages, :only => [:create, :update]
  
  def prepare_project_list
    @project_list = Project.all.map{|pack| [pack.name, pack.id]}
  end
  
  def index
    if pid = params[:project_id]
      @packs = Pack.where :project_id => pid
    else
      @packs = Pack.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @packs }
    end
  end

  # GET /packs/1
  # GET /packs/1.json
  def show
    @pack          = Pack.find(params[:id])
    @categories    = @pack.categories.sort
    @force_refresh = true if params[:refresh] == 'true'
    @stats         = @pack.compute_all_stats @force_refresh
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pack }
    end
  end

  # GET /packs/new
  # GET /packs/new.json
  def new
    @pack = Pack.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pack }
    end
  end

  # GET /packs/1/edit
  def edit
    @pack = Pack.find(params[:id])
  end

  # POST /packs
  # POST /packs.json
  def create
    @pack = Pack.new(params[:pack])
    @pack.user_id = current_user.id
    
    respond_to do |format|
      if @pack.save
        format.html { redirect_to @pack, notice: 'Pack was successfully created.' }
        format.json { render json: @pack, status: :created, location: @pack }
      else
        format.html { render action: "new" }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /packs/1
  # PUT /packs/1.json
  def update
    @pack = Pack.find(params[:id])
    
    respond_to do |format|
      if @pack.update_attributes(params[:pack])
        format.html { redirect_to @pack, notice: 'Pack was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packs/1
  # DELETE /packs/1.json
  def destroy
    @pack = Pack.find(params[:id])
    @pack.destroy

    respond_to do |format|
      format.html { redirect_to packs_url }
      format.json { head :no_content }
    end
  end
  
  def add_messages
    if @pack and @pack.id and @pack.errors.empty?
      if upload = params[:csv_file]
         messages = MessagesAdapter.adapt_csv upload
         Resque.enqueue MessagesImportJob, current_user.id, @pack.id, messages
         flash[:notice] += " Adding messages in the background! (may take a while)"
      end
    end
  end
  
  def translate
    @pack  = Pack.find params[:id]
    
    @langs = Language.all.map {|language| [language.name, language.id]}
    @cats  = ["*"] + @pack.classifications.select('category').group('category').order('category').map {|classification| classification.category}
    
    unless params[:source_language_id]
      params[:source_language_id] = Language.find_by_code("en").id
    end
    
    current_user.last_translation_url = url_for(params)
    current_user.save
    
    if params[:category] and params[:language_id]
      #@classifs = @pack.classifications.where(:category => params[:category]).page(params[:page])
      translations_conditions = {:language_id => params[:language_id]}
      
      like = []
      unless params[:like].to_s.strip.empty?
        like = Translation.arel_table[:string].matches(params[:like])
      end
      
      if params[:empty] == '2'      #allow empty translations
        translations_conditions = Hash[*translations_conditions.map{|k,v| [k, (if v.class == Array then v else [v] end) + [nil]]}.inject(:+)]
      elsif params[:empty] == '1'   #take only empty translations
        translations_conditions = {:id => nil}
      end

      classifications_conditions = if params[:category] == '*' then {} else {:category => params[:category]} end

      gpp = if params[:category] == 'Modules' then 25 else 25 end

      @classifs = @pack.classifications
                  .select('classifications.id, classifications.group').uniq
                  .joins(:messages)
                  .joins("LEFT OUTER JOIN current_translations ON current_translations.message_id = messages.id AND current_translations.language_id = #{params[:language_id].to_i} AND current_translations.pack_id = #{params[:id].to_i}")
                  .joins("LEFT OUTER JOIN translations ON translations.id = current_translations.translation_id")
                  .where(
                          :translations => translations_conditions,
                          :classifications => classifications_conditions
                        )
                  .where(like)
                  .abacus
                  .page(params[:page]).per(gpp)
                    
        #debugger
    end
    
  end
  
  def post_translation
    
    answer = {:success => false}
    
    source = Source.find_or_create_by_name("USER")
    
    message     = Message.find(params[:message_id])
    translation = Translation.new(params[:translation])
    translation.language_id = params[:language_id]
    translation.key = message.key
    
    if translation.string.strip.empty?
      current_user.notify "Cannot save empty translation!", :error
    end
    
    translation.user_id   =  current_user.id
    translation.source_id =  source.id
    
    if translation.save
      Pack.all.each do |pack|
        pack.update_current_translation_with translation
      end
      answer[:success] = true
    end
    
    respond_to do |format|
      format.json {render json: answer}
    end
  end
  
  def export
    Resque.enqueue PackBuildJob, current_user.id, params[:id], params[:language_id]
    flash[:notice] = "Building pack!"
    redirect_to pack_path(params[:id])
  end
  
  def grind
    Resque.enqueue PackGrindJob, current_user.id, params[:id], params[:language_id]
    flash[:notice] = "Ok ok, I do it."
    redirect_to pack_path(params[:id])
  end
  
end
