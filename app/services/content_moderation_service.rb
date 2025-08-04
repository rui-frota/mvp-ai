class ContentModerationService
  include ActiveSupport::Configurable

  # Configurações padrão
  config_accessor :enabled, default: true
  config_accessor :strict_mode, default: false
  config_accessor :custom_blocked_words, default: []
  config_accessor :max_input_length, default: 10000
  config_accessor :block_personal_info, default: true

  # Palavras sensíveis em português e inglês
  SENSITIVE_TOPICS = %w[
    suicide suicídio
    violence violência 
    terrorism terrorismo
    drugs drogas
    fraud fraude
    illegal ilegal
    hate ódio
    discrimination discriminação
    harassment assédio
    abuse abuso
    bomba bomb
    explosivo explosive
    arma weapon
    matar kill
    morte death
    veneno poison
  ].freeze

  # Padrões para informações pessoais
  PERSONAL_INFO_PATTERNS = {
    cpf: /\d{3}\.?\d{3}\.?\d{3}-?\d{2}/,
    phone: /\(?\d{2}\)?\s?\d{4,5}-?\d{4}/,
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
    credit_card: /\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}/
  }.freeze

  class << self
    def moderate_input(text)
      return { approved: true, reasons: [] } unless config.enabled
      
      violations = []
      
      # Verificar comprimento
      if text.length > config.max_input_length
        violations << "Texto muito longo (máximo #{config.max_input_length} caracteres)"
      end
      
      # Verificar profanidade
      if contains_profanity?(text)
        violations << "Conteúdo ofensivo detectado"
      end
      
      # Verificar tópicos sensíveis
      if contains_sensitive_topics?(text)
        violations << "Conteúdo sobre tópicos sensíveis"
      end
      
      # Verificar informações pessoais
      if config.block_personal_info && contains_personal_info?(text)
        violations << "Possível informação pessoal detectada"
      end
      
      # Verificar palavras customizadas
      if contains_custom_blocked_words?(text)
        violations << "Conteúdo bloqueado por filtros customizados"
      end
      
      {
        approved: violations.empty?,
        reasons: violations,
        risk_level: calculate_risk_level(violations)
      }
    end
    
    def moderate_output(text)
      return { approved: true, reasons: [] } unless config.enabled
      
      violations = []
      
      # Verificações mais rigorosas para output
      if contains_harmful_instructions?(text)
        violations << "Instruções potencialmente perigosas"
      end
      
      if contains_misinformation_patterns?(text)
        violations << "Possível desinformação"
      end
      
      if config.strict_mode && contains_any_sensitive_content?(text)
        violations << "Conteúdo sensível (modo estrito ativado)"
      end
      
      {
        approved: violations.empty?,
        reasons: violations,
        text: violations.empty? ? text : sanitize_output(text),
        risk_level: calculate_risk_level(violations)
      }
    end
    
    private
    
    def contains_profanity?(text)
      # Usar a gem obscenity
      Obscenity.profane?(text.downcase)
    rescue => e
      Rails.logger.warn "Erro na verificação de profanidade: #{e.message}"
      false
    end
    
    def contains_sensitive_topics?(text)
      normalized_text = text.downcase.unicode_normalize
      SENSITIVE_TOPICS.any? { |topic| normalized_text.include?(topic) }
    end
    
    def contains_personal_info?(text)
      PERSONAL_INFO_PATTERNS.any? { |type, pattern| text.match?(pattern) }
    end
    
    def contains_custom_blocked_words?(text)
      return false if config.custom_blocked_words.empty?
      
      normalized_text = text.downcase.unicode_normalize
      config.custom_blocked_words.any? { |word| normalized_text.include?(word.downcase) }
    end
    
    def contains_harmful_instructions?(text)
      harmful_patterns = [
        /como\s+fazer\s+(bomba|explosivo|veneno)/i,
        /how\s+to\s+(make|create)\s+(bomb|explosive|poison)/i,
        /instruções\s+para\s+(hackear|invadir)/i,
        /tutorial\s+(illegal|crime)/i
      ]
      
      harmful_patterns.any? { |pattern| text.match?(pattern) }
    end
    
    def contains_misinformation_patterns?(text)
      # Padrões que podem indicar desinformação
      misinformation_indicators = [
        /comprovado\s+cientificamente\s+que.*não/i,
        /todos\s+os\s+(médicos|cientistas)\s+concordam/i,
        /a\s+(mídia|imprensa)\s+esconde/i,
        /theory\s+proves\s+that/i,
        /scientists\s+don't\s+want\s+you\s+to\s+know/i
      ]
      
      misinformation_indicators.any? { |pattern| text.match?(pattern) }
    end
    
    def contains_any_sensitive_content?(text)
      contains_profanity?(text) || 
      contains_sensitive_topics?(text) || 
      contains_personal_info?(text)
    end
    
    def calculate_risk_level(violations)
      case violations.size
      when 0
        :safe
      when 1
        :low
      when 2..3
        :medium
      else
        :high
      end
    end
    
    def sanitize_output(text)
      # Versão sanitizada do texto
      "⚠️ Conteúdo moderado: Este texto foi filtrado por conter informações potencialmente inadequadas."
    end
  end
end
