class Support::TicketsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @ticket = Support::Ticket.new
  end

  def create
    @ticket = Support::Ticket.new(ticket_params)
    @ticket.user = get_user
    @ticket.status = 'pending'
    if @ticket.save
      redirect_to root_path, notice: 'Submitted successfully!'
    else
      render :new
    end
  end

  private

  def ticket_params
    params.require(:support_ticket).permit(:email, :subject, :message)
  end

  def get_user
    current_user || User.find_by(email: params[:email])
  end

  # end of private

end
