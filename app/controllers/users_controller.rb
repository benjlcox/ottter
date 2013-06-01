class UsersController < ApplicationController

  before_filter :save_login_state, :only => [:new, :create]


  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html   
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

# GET /users/1/confirm
  def confirm
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to confirm_path(@user), notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
        session[:user_id] = @user.id
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to "/home", notice: 'Congrats. Your profile was successfully created/updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "confirm" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    session[:user_id] = nil
    @user.destroy

    respond_to do |format|
      format.html { redirect_to root_url, notice: "Your account has been deleted. Please come back." }
      format.json { head :no_content }
    end
  end
end
