class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :nickname, :image, :rating, :num_wins, :num_matches, :num_losses
end
