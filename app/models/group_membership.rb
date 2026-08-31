class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :status, { invited: 0, accepted: 1, declined: 2 }, default: :invited

  validates :user_id, uniqueness: { scope: :group_id }

  after_commit :broadcast_invitation_update

  private

  def broadcast_invitation_update
    broadcast_replace_to [ user, "group_memberships" ],
                         target: "groups_sidebar_item_#{user.id}",
                         partial: "groups/partials/sidebar_item",
                         locals: { user: user }
  end
end
