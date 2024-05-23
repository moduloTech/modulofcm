# frozen_string_literal: true

require_relative 'file_i_o'
require_relative 'response'

# rubocop:disable Metrics/ParameterLists
module Modulofcm

  class Client

    attr_reader :name, :api_key, :google_application_credentials, :firebase_project_id, :mode

    def initialize(name:, api_key: nil,
                   google_application_credentials_path: nil, google_application_credentials: nil,
                   firebase_project_id: nil)
      @name = name.to_sym
      @api_key = api_key
      @google_application_credentials_path = google_application_credentials_path
      @google_application_credentials = google_application_credentials
      @firebase_project_id = firebase_project_id
      @mode = :api_v1
    end

    # All keyword arguments are optional and references a field in Firebase documentation:
    # Legacy API: https://firebase.google.com/docs/cloud-messaging/http-server-ref
    # APIv1 : https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages
    #  title: The notification's title.
    #    Legacy: `notification.title`
    #    APIv1: `message.notification.title`
    #  body: The notification's body text.
    #    Legacy: `notification.body`
    #    APIv1: `message.notification.body`,
    #  sound: The sound to play when the device receives the notification.
    #    Legacy: `notification.sound`
    #    APIv1:
    #      android: `message.android.sound`
    #      ios: `message.apns.aps.sound`
    #  content_available: Allow to awaken the iOS app.
    #    Legacy: `content_available` - ignored on non-iOS devices.
    #    APIv1:
    #      ios: `message.apns.aps.content-available`
    #  data: Arbitrary key/value payload, which must be UTF-8 encoded. The key should not be a reserved word
    #    ("from", "message_type", or any word starting with "google" or "gcm").
    #    Legacy: `data`
    #    APIv1: `message.data`
    def push(token, data: nil, title: nil, body: nil, sound: nil, content_available: true)
      raise NoTokenError if token.blank?
      raise EmptyNotificationError if data.blank? && title.blank? && body.blank?

      case @mode
      when :legacy
        push_legacy(token, data: data, title: title, body: body, sound: sound, content_available: content_available)
      else
        push_v1(token, data: data, title: title, body: body, sound: sound, content_available: content_available)
      end
    end

    %w[
        api_key firebase_project_id google_application_credentials_path google_application_credentials
      ].each do |attribute|
      define_method("#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", value)

        update_mode
      end
    end

    def google_application_credentials_path
      if @google_application_credentials_path.present? || @google_application_credentials.blank?
        return @google_application_credentials_path
      end

      @google_application_credentials_path = if @google_application_credentials.is_a?(String)
                                               FileIO.new(@google_application_credentials, 'creds.json')
                                             elsif @google_application_credentials.respond_to?(:to_json)
                                               FileIO.new(@google_application_credentials.to_json, 'creds.json')
                                             else
                                               @google_application_credentials
                                             end
    end

    private

    def update_mode
      api_v1_fields_all_present = [google_application_credentials_path, firebase_project_id].all?(&:present?)
      api_key_blank = api_key.blank?

      @mode = if api_v1_fields_all_present || api_key_blank
                :api_v1
              else
                :legacy
              end

      @client = case @mode
                when :legacy
                  FCM.new(api_key)
                else
                  FCM.new('', google_application_credentials_path, firebase_project_id)
                end
    end

    def push_legacy(token, data: nil, title: nil, body: nil, sound: nil, content_available: true)
      payload = default_payload(content_available)

      handle_data(payload, data)
      handle_notification(payload, body, sound, title)

      make_legacy_response(@client.send(token, payload))
    end

    def push_v1(token, data: nil, title: nil, body: nil, sound: nil, content_available: true)
      payload = default_payload(content_available)
      payload[:token] = token

      handle_data(payload, data)
      handle_notification(payload, body, sound, title)

      # According to Firebase documentation, all values must be strings. So all hashes/arrays are JSON-ified and other
      # fields (including numbers) are converted to strings.
      payload[:data].transform_values! do |value|
        if value.is_a?(Hash) || value.is_a?(Array)
          value.to_json
        else
          value.to_s
        end
      end

      make_v1_response(@client.send_v1(payload))
    end

    def default_payload(content_available)
      case @mode
      when :legacy
        {
          content_available: !content_available.nil?
        }
      else
        {
          android: { 
            priority: "high" 
          },
          apns: {
            payload: {
              aps: {
                'content-available' => content_available ? 1 : 0
              }
            }
          }
        }
      end
    end

    def handle_notification(payload, body, sound, title)
      payload[:notification] = {} if [title, body, sound].any?(&:present?)

      { title: title, body: body, sound: sound }.each do |key, value|
        next if value.blank?

        send("handle_notification_#{key}", payload, value)
        payload[:data].merge!(key => value) if payload[:data].present?
      end
    end

    def handle_notification_title(payload, value)
      payload[:notification][:title] = value
    end

    def handle_notification_body(payload, value)
      payload[:notification][:body] = value
    end

    def handle_notification_sound(payload, value)
      case @mode
      when :legacy
        payload[:notification][:sound] = value
      else
        payload[:apns][:payload][:aps][:sound] = value
        payload[:android][:sound] = value
      end
    end

    def handle_data(payload, data)
      payload[:data] = data if data.present?
    end

    def make_v1_response(response)
      response_body = JSON.parse(response[:body])

      Response.new(success: response[:response] == 'success',
                   status: response[:status_code], body: response_body)
    end

    def make_legacy_response(response)
      response_body = JSON.parse(response[:body])

      Response.new(success: response_body['success'].positive? && response_body['failure'].zero?,
                   status: response[:status_code], body: response_body)
    end

  end

end
# rubocop:enable Metrics/ParameterLists
