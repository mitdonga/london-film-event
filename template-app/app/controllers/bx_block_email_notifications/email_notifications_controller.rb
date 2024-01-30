module BxBlockEmailNotifications
  class EmailNotificationsController < ApplicationController

    def index
      @all_notifications = EmailNotification.all
      if @all_notifications
        render json: EmailNotificationSerializer.new(@all_notifications).serializable_hash,
               status: :ok
      end
    end

    def notification_list
      @notifications = EmailNotification.order(created_at: :desc).limit(5)
      if @notifications
        render json: EmailNotificationSerializer.new(@all_notifications).serializable_hash,
               status: :ok
      end
    end

    def show
      email_notification = EmailNotification.joins(:notification).find_by(
        id: params[:id],
        notifications: {account_id: current_user.id}
      )

      if email_notification
        render json: EmailNotificationSerializer.new(email_notification).serializable_hash,
               status: :ok
      else
        render json: {errors: [{message: 'Email Notification not found.'},]}, status: :not_found
      end
    end

    def create
      notification = BxBlockNotifications::Notification.find_by(
        id: params[:notification_id],
        account_id: current_user.id
      )

      if notification
        email_notification = SendEmailNotificationService.new(notification).call

        render json: EmailNotificationSerializer.new(email_notification).serializable_hash,
               status: :ok
      else
        render json: {errors: [{message: 'Notification not found.'},]}, status: :not_found
      end
    end
  end
end
