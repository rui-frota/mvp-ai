# Configurações do sistema de moderação de conteúdo
Rails.application.config.after_initialize do
  ContentModerationService.configure do |config|
    # Habilitar moderação em desenvolvimento também para testes
    config.enabled = true
    
    # Modo estrito (mais rigoroso)
    config.strict_mode = Rails.env.production?
    
    # Comprimento máximo do input (10KB)
    config.max_input_length = 10_000
    
    # Bloquear informações pessoais
    config.block_personal_info = true
    
    # Palavras customizadas bloqueadas (adicione conforme necessário)
    config.custom_blocked_words = [
      # Adicione palavras específicas do seu domínio
      'palavra_bloqueada_exemplo'
    ]
  end

  # Configurar a gem Obscenity
  if defined?(Obscenity)
    # Adicionar mais palavras ofensivas à lista
    additional_words = %w[
      merda porra caralho puta fdp filho da puta
      shit fuck damn bitch ass hell asshole
      idiota imbecil estúpido burro
      stupid idiot moron dumb
      desgraça desgraçado
      bastard
    ]
    
    Obscenity::Base.blacklist = (Obscenity::Base.blacklist + additional_words).uniq
    
    Rails.logger.info "✅ Obscenity configurado com #{Obscenity::Base.blacklist.size} palavras"
  end

  Rails.logger.info "✅ Sistema de moderação de conteúdo configurado"
  Rails.logger.info "   - Habilitado: #{ContentModerationService.config.enabled}"
  Rails.logger.info "   - Modo estrito: #{ContentModerationService.config.strict_mode}"
  Rails.logger.info "   - Máx. caracteres: #{ContentModerationService.config.max_input_length}"
end
