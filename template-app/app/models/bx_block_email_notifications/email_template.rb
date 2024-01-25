module BxBlockEmailNotifications
    class EmailTemplate < ApplicationRecord
        self.table_name = :email_templates

        before_validation :arrange_dynamic_words

        validates :name, presence: true, uniqueness: true
        validates :body, :dynamic_words, presence: true
        validates :images, :content_type => ["jpg", "png", "jpeg", "image/jpg", "image/jpeg", "image/png"]
        validate :check_email_body

        has_many_attached :images

        private

        def arrange_dynamic_words
            self.dynamic_words = sanitize_string(self.dynamic_words)
        end

        def check_email_body
            words = dynamic_words.split(',').select(&:present?).map {|w| "{#{w.strip}}"}
            matches = body.scan(/\{([^}]+)\}/)
            matches.each do |word|
                errors.add(:body, "must not contain {#{word[0]}} because it's not a dynamic word") and return unless dynamic_words.include?(word[0])
            end
        end

        def sanitize_string(str)
            return unless str.present?
            str.to_s.split(",").select {|e| e.present?}.map {|e| e.strip}.uniq.join(", ")
        end
    end
end
