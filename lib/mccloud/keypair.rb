require 'mccloud/util/sshkey'

module Mccloud
  class Keypair
    attr_accessor :public_key_path
    attr_accessor :private_key_path
    attr_accessor :name
    attr_accessor :env

    def initialize(name,env)
      @name=name
      @env=env
      @private_key_path=File.join(env.ssh_key_path,"#{name}_rsa")
      @public_key_path=File.join(env.ssh_key_path,"#{name}_rsa.pub")
      return self
    end

    def exists?
      return false unless File.exists?(@public_key_path)
      return false unless File.exists?(@private_key_path)
      return true
    end

    def generate(options={:force => false})
      force=options[:force]
      if exists? && force==false
        env.ui.error "Keypair: #{@name} already exists"
        env.ui.error "- #{@public_key_path}"
        env.ui.error "- #{@private_key_path}"
        raise ::Mccloud::Error, "Keypair #{@name} already exists"
      else
        env.ui.info "Generating Keypair: #{@name}"
        env.ui.info "- #{@public_key_path}"
        env.ui.info "- #{@private_key_path}"
        env.ui.info ""
        env.ui.warn "Make sure you make a backup!!"
        rsa_key=::Mccloud::Util::SSHKey.generate({ :comment => "Key generated by mccloud #{@name}"})
        begin
          File.open(@public_key_path,'w'){|f| f.write(rsa_key.ssh_public_key)}
          File.open(@private_key_path,'w'){|f| f.write(rsa_key.rsa_private_key)}
        rescue Exception => ex
          env.ui.error "Error generating keypair : #{ex}"
        end
      end
    end

  end
end
