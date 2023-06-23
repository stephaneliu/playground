# frozen_string_literal: true

class User < ApplicationRecord
  before_save :set_default_preferences

  store_accessor :notify_preferences, :mentions_in_app, :mentions_push, :mentions_email
  store_accessor :notify_preferences, :photo_comments_in_app, :photo_comments_push, :photo_comments_email
  store_accessor :notify_preferences, :responses_in_app, :responses_push, :responses_email
  store_accessor :notify_preferences, :assignments_in_app, :assignments_push, :assignments_email
  store_accessor :notify_preferences, :document_signatures_in_app, :document_signatures_push, :document_signatures_email
  store_accessor :notify_preferences, :collaborations_in_app, :collaborations_push, :collaborations_email

  store_accessor :notify_preferences, :collaboration_relevant_to_user

  scope :mentions_notification,
        ->(delivery_method, val) { where("notify_preferences->>'mentions_#{delivery_method}' = ?", val.to_s) }

  scope :photo_comments_notification,
        ->(delivery_method, val) { where("notify_preferences->>'photo_comments_#{delivery_method}' = ?", val.to_s) }

  scope :responses_notification,
        ->(delivery_method, val) { where("notify_preferences->>'responses_#{delivery_method}' = ?", val.to_s) }

  scope :assignments_notification,
        ->(_deliery_method, val) { where("notify_preferences->>'assignments_#{delivery_method}' = ?", val.to_s) }

  scope :document_signatures_notification,
        lambda { |delivery_method, val|
          where("notify_preferences->>'document_signatures_#{delivery_method}' = ?", val.to_s)
        }

  scope :collabs_notification,
        ->(delivery_method, val) { where("notify_preferences->>'collaborations_#{delivery_method}' = ?", val.to_s) }

  scope :relevant_collab_notification,
        ->(val) { where("notify_preferences->>'collaboration_relevant_to_user' = ?", val.to_s) }

  private

  def set_default_preferences
    User.stored_attributes[:notify_preferences].each do |preference|
      send("#{preference}=", preference_default_value(preference)) if send(preference).nil?
    end
  end

  def preference_default_value(preference)
    email_notification          = preference.to_s.ends_with?('email')
    collaborations_notification = preference.to_s.starts_with?('collaborations')

    !(email_notification || collaborations_notification)
  end
end
