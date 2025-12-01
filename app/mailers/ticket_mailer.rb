class TicketMailer < ApplicationMailer
    default from: "csce606Project3@sandbox730d2528719d4c12aaf0f9c0b1f35576.mailgun.org"

    def ticket_updated_email
        @ticket = params[:ticket]
        @user = @ticket.requester

        recipient_email = @user.personal_email.present? ? @user.personal_email : @user.email

        mail(to: recipient_email, subject: "[Ticket ##{@ticket.id}] Update: #{@ticket.subject}")
    end
end
