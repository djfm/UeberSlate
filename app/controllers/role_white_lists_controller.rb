class RoleWhiteListsController < ApplicationController
  # GET /role_white_lists
  # GET /role_white_lists.json
  def index
    @role_white_lists = RoleWhiteList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @role_white_lists }
    end
  end

  # GET /role_white_lists/1
  # GET /role_white_lists/1.json
  def show
    @role_white_list = RoleWhiteList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @role_white_list }
    end
  end

  # GET /role_white_lists/new
  # GET /role_white_lists/new.json
  def new
    @role_white_list = RoleWhiteList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @role_white_list }
    end
  end

  # GET /role_white_lists/1/edit
  def edit
    @role_white_list = RoleWhiteList.find(params[:id])
  end

  # POST /role_white_lists
  # POST /role_white_lists.json
  def create
    @role_white_list = RoleWhiteList.new(params[:role_white_list])
    
    puts @role_white_list.inspect

    respond_to do |format|
      if @role_white_list.save
        format.html { redirect_to params[:redirect], notice: 'Role white list was successfully created.' }
        format.json { render json: @role_white_list, status: :created, location: @role_white_list }
      else
        format.html { render action: "new" }
        format.json { render json: @role_white_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /role_white_lists/1
  # PUT /role_white_lists/1.json
  def update
    @role_white_list = RoleWhiteList.find(params[:id])

    respond_to do |format|
      if @role_white_list.update_attributes(params[:role_white_list])
        format.html { redirect_to @role_white_list, notice: 'Role white list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @role_white_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_white_lists/1
  # DELETE /role_white_lists/1.json
  def destroy
    @role_white_list = RoleWhiteList.find(params[:id])
    @role_white_list.destroy

    respond_to do |format|
      format.html { redirect_to params[:redirect] or role_white_lists_url }
      format.json { head :no_content }
    end
  end
end
