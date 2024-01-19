module BxBlockEmailNotifications
    class EmailTemplate < ApplicationRecord
        self.table_name = :email_templates

        validates :name, presence: true, uniqueness: true
        validates :images, :content_type => ["jpg", "png", "jpeg", "image/jpg", "image/jpeg", "image/png", "svg", "image/svg+xml"]

        has_many_attached :images

    end
end
