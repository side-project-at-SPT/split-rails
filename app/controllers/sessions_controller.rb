class SessionsController < ApplicationController
  def new
    @visitor = Visitor.new
  end

  def create
    user = Visitor.find_or_initialize_by(name: session_params[:name])

    if user.new_record?
      user.password = session_params[:password]
      user.save!
      session[:user_id] = user.id
      return redirect_to root_path, notice: "Logged in!"
    end

    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in!"
    else
      @visitor = Visitor.new
      @visitor.errors.add(:base, "Name or password is invalid")
      render "new", status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out!"
  end

  private

  def session_params
    params.require(:visitor).permit(:name, :password)
  end
end
