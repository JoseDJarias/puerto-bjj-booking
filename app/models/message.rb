class Message < ApplicationRecord
  belongs_to :group
  belongs_to :user

  has_many_attached :attachments

  validates :content, presence: true, unless: -> { attachments.attached? }

  after_create_commit :broadcast_message

  private

  def broadcast_message
    broadcast_append_to "group_#{group_id}_messages",
                        target: "group_#{group_id}_messages_list",
                        partial: "messages/message",
                        locals: { message: self }
  end
end
