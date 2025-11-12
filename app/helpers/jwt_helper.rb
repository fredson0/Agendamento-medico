module JwtHelper
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'fallback_secret_key_for_development'
  
  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    payload[:iat] = Time.current.to_i
    
    JWT.encode(payload, SECRET_KEY, 'HS256')
  rescue => e
    Rails.logger.error "JWT Encode Error: #{e.message}"
    nil
  end
  
  def self.decode(token)
    return nil if token.blank?
    
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    decoded.first.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.warn "JWT Decode Error: #{e.message}"
    nil
  rescue => e
    Rails.logger.error "JWT Unexpected Error: #{e.message}"
    nil
  end
  
  def self.valid_token?(token)
    decoded = decode(token)
    decoded.present? && !expired_payload?(decoded)
  end
  
  def self.expired?(token)
    decoded = decode(token)
    return true unless decoded
    expired_payload?(decoded)
  end
  
  def self.user_from_token(token)
    decoded = decode(token)
    return nil unless decoded && !expired_payload?(decoded)
    
    user_id = decoded[:user_id] || decoded['user_id']
    return nil unless user_id
    
    Usuario.find_by(id: user_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
  private_class_method def self.expired_payload?(payload)
    return true unless payload
    
    exp = payload[:exp] || payload['exp']
    return true unless exp
    
    Time.current.to_i > exp.to_i
  end
end