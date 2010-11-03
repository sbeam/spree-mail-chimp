module MailChimp
  class Config < ActiveResource::Base
    # O self.site tem q ser configurado no environment!
  end
  class Contact < Config
    def self.find_by_internal_id iid
      find(:first, :params => {:internal_id => iid})
    end
    def unsubscribe(data={})
      #E.g. data --> {:reason => 'Trip to nowhere', :spam => false}
      put(:unsubscribe, :unsubscribe => {:reason => 'Motivo não especificado'}.merge(data))
    end
  end
  class List < Config
  end
  
  module Sync
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
        
      def sync_with_mailchimp(options = {})
        unless syncd? # don't let AR call this twice
          cattr_accessor :sync_options
          after_create :create_in_mailchimp
          after_update :update_in_mailchimp
          after_destroy :destroy_in_mailchimp
          self.sync_options = {:email => :email, :name => :name, :news => :news}.merge(options)
        end
        include InstanceMethods
      end

      def syncd?
        self.included_modules.include?(InstanceMethods)
      end
    end
    
      
    module InstanceMethods #:nodoc:
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end
      
      def create_in_mailchimp
        return unless self.is_mail_list_subscriber
        mc_list_id = Spree::Config.get(:mailchimp_list_id)
        self.class.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
          hom = Hominid::Base.new({:api_key => Spree::Config.get(:mailchimp_api_key)})
          hom.subscribe(mc_list_id, self.email, {:email_type => 'html', :secure => true})
        end
      rescue
        logger.warn "mailchimp-API: Failed to create contact #{id} in mailchimp: #{$1}"
      end

      def update_in_mailchimp
        self.class.benchmark "Atualizando contato no mailchimp" do

          contact = mailchimp::Contact.find_by_internal_id id

          if contact
            #Se o contato existe e o booleano foi desmarcado, realiza um UNSUBSCRIBE
            if sync_options[:news] and (! send(sync_options[:news]))
              unsubscribe_in_mailchimp(contact)
            else
              contact.email = send(sync_options[:email])
              contact.name = send(sync_options[:name]) if sync_options[:name]
              contact.save
            end
          else
            create_in_mailchimp # Se não achou o contato tem q inserir.
          end
        end
      rescue
        logger.warn "mailchimp-API: Falhou ao atualizar o contato #{id} no mailchimp"
      end

      def destroy_in_mailchimp contact=nil
        self.class.benchmark "Excluindo contato no mailchimp" do

          contact ||= mailchimp::Contact.find_by_internal_id id

          contact.destroy
        end
      rescue
        logger.warn "mailchimp-API: Falhou ao excluir o contato #{id} no mailchimp"
      end

      def unsubscribe_in_mailchimp contact=nil
        self.class.benchmark "Descadastrando contato no mailchimp" do

          contact ||= mailchimp::Contact.find_by_internal_id id

          contact.unsubscribe
        end
      rescue
        logger.warn "mailchimp-API: Falhou ao descadastrar o contato #{id} no mailchimp"
      end
      
      module ClassMethods
        # Sincroniza todos os itens do modelo com mailchimp.
        # Permite que se passe um datetime para enviar apenas os contatos atualizados depois desta data
        # Permite o uso de um bloco, que receberá o item do modelo e o item do mailchimp associado a este.
        # Ex: Contact.send_all_to_mailchimp{|i,im| im.address = i.endereco; im.save }
        # Importante: este método apenas envia os contatos, mas não recebe.
        # Para receber contatos, o ideal é fazer uma exportação no mailchimp e realizar uma importação deste arquivo CSV no seu sistema.
        
        def send_all_to_mailchimp(after=nil)
          items = after ? all(:conditions => ["updated_at >= ?", after]) : all
          for item in items
            begin

              contact = mailchimp::Contact.find_by_internal_id item.id

              if contact and sync_options[:news] and ! item.send(sync_options[:news])
                contact.unsubscribe
                yield item, contact if block_given?
                next
              end
              unless contact
                next if sync_options[:news] and ! item.send(sync_options[:news])
                contact = mailchimp::Contact.new
                contact.internal_id = item.id
              end
              contact.email = item.send(sync_options[:email])
              contact.name = item.send(sync_options[:name]) if sync_options[:name]
              contact.save
              yield item, contact if block_given?
            rescue
              logger.warn "mailchimp-API: Falhou ao enviar o contato #{id} ao mailchimp"
            end
          end
        end
      end
      
    end
    
    
  end


  
  


          
end
