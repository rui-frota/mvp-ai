namespace :content_moderation do
  desc "Testa o sistema de moderação de conteúdo"
  task test: :environment do
    puts "🛡️ Testando sistema de moderação de conteúdo...\n"

    test_cases = [
      {
        name: "Texto normal",
        text: "Como posso melhorar meu texto de apresentação?",
        expected: true
      },
      {
        name: "Texto ofensivo",
        text: "Este texto contém palavrões como merda e porra",
        expected: false
      },
      {
        name: "Informação pessoal - CPF",
        text: "Meu CPF é 123.456.789-00",
        expected: false
      },
      {
        name: "Informação pessoal - Email",
        text: "Entre em contato comigo em usuario@email.com",
        expected: false
      },
      {
        name: "Tópico sensível",
        text: "Como fazer uma bomba caseira?",
        expected: false
      },
      {
        name: "Texto muito longo",
        text: "a" * 15000,
        expected: false
      }
    ]

    test_cases.each do |test_case|
      result = ContentModerationService.moderate_input(test_case[:text])
      
      status = result[:approved] == test_case[:expected] ? "✅ PASSOU" : "❌ FALHOU"
      
      puts "#{status} - #{test_case[:name]}"
      puts "  Aprovado: #{result[:approved]}"
      puts "  Razões: #{result[:reasons].join(', ')}" unless result[:reasons].empty?
      puts "  Nível de risco: #{result[:risk_level]}"
      puts ""
    end

    puts "🏁 Teste concluído!"
  end

  desc "Mostra configurações atuais do sistema de moderação"
  task config: :environment do
    puts "🛡️ Configurações do Sistema de Moderação:"
    puts "  Habilitado: #{ContentModerationService.config.enabled}"
    puts "  Modo estrito: #{ContentModerationService.config.strict_mode}"
    puts "  Máx. caracteres: #{ContentModerationService.config.max_input_length}"
    puts "  Bloquear info pessoal: #{ContentModerationService.config.block_personal_info}"
    puts "  Palavras customizadas: #{ContentModerationService.config.custom_blocked_words.size}"
  end
end
