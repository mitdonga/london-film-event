module BxBlockEmailNotifications
    class EmailTemplate < ApplicationRecord
        self.table_name = :email_templates

        validates :name, presence: true, uniqueness: true
        validates :body, :dynamic_words, presence: true
        validates :images, :content_type => ["jpg", "png", "jpeg", "image/jpg", "image/jpeg", "image/png"]
        validate :check_email_body

        has_many_attached :images

        private

        def check_email_body
            words = dynamic_words.split(',').select(&:present?).map {|w| "{#{w.strip}}"}
            words.each do |word|
                errors.add(:body, "must contain #{word}") unless body.include?(word)
            end
        end
    end
end
