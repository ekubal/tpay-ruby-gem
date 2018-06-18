module Tpay

	class Error < Exception; attr_accessor :errors; end
	
  # ID of receiver
  @@id = ''
  @@security_code = ''
  def self.id=(new_id)
    @@id = new_id
  end

  def self.id
    @@id
  end

  # Security code
  def self.security_code=(new_security_code)
    @@security_code = new_security_code
  end

  def self.security_code
    @@security_code
  end

	# Creates URL for redirection to pay page
	def self.pay_url(params = {})
		self.sanity_check!
		md5sum = Digest::MD5.hexdigest(self.id.to_s+params[:kwota].to_s+params[:crc].to_s+self.security_code.to_s)
		params.merge!({id: self.id, md5sum: md5sum})
		URI::HTTPS.build(host: "secure.tpay.com", query: params.to_query).to_s
	end

  # Checks MD5 checksum and IP of request
	def self.webhook_valid?(transaction, ip)
		self.sanity_check!
		md5sum = Digest::MD5.hexdigest(self.id.to_s+transaction[:tr_id].to_s+transaction[:tr_amount].to_s+transaction[:tr_crc].to_s+self.security_code.to_s)
    valid_ip?(ip) && transaction[:md5sum] == md5sum
	end

	def self.configured?
    self.id.present? && self.security_code.present?
  end

  def self.sanity_check!
    unless configured?
      raise Exception.new("Tpay Gem not properly configured. See README to get help how to do it.")
    end
  end

  class Client
    attr_accessor :id, :security_code

    def initialize(id, security_code)
      @id, @security_code = id, security_code
    end

    # Creates URL for redirection to pay page
    def pay_url(params = {})
      sanity_check!
      md5sum = Digest::MD5.hexdigest([
                                        id,
                                        params[:kwota],
                                        params[:crc],
                                        security_code
                                      ].join)
      params.merge!({id: id, md5sum: md5sum})
      URI::HTTPS.build(host: "secure.tpay.com", query: params.to_query).to_s
    end

    # Checks MD5 checksum and IP of request
    def webhook_valid?(transaction, ip)
      sanity_check!
      md5sum = Digest::MD5.hexdigest([
                                        id,
                                        transaction[:tr_id],
                                        transaction[:tr_amount],
                                        transaction[:tr_crc],
                                        security_code
                                      ].join)
      valid_ip?(ip) && transaction[:md5sum] == md5sum
    end

    def self.valid_ip?(ip)
      ['195.149.229.109', '148.251.96.163', '178.32.201.77', 
       '46.248.167.59', '46.29.19.106', '176.119.38.175'].member?(ip)
    end


    def configured?
      id.present? && security_code.present?
    end

    def sanity_check!
      unless configured?
        raise Exception.new("Tpay Gem not properly configured. See README to get help how to do it.")
      end
    end
  end
end
