class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      email: @user.email,
      created_at: @user.created_at
    }
  end

  def serializable_hash
    {
      data: {
        type: 'user',
        id: @user.id.to_s,
        attributes: as_json
      }
    }
  end
  
  # Class method for collections
  def self.collection(users)
    users.map { |user| new(user).as_json }
  end
end
