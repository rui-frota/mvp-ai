namespace :content_moderation do
  desc "Teste abrangente do sistema de moderação"
  task extended_test: :environment do
    puts "🛡️ Teste abrangente do sistema de moderação..."
    puts "=" * 60

    test_cases = [
      # Casos positivos (devem passar)
      {
        category: "✅ CASOS POSITIVOS",
        tests: [
          { name: "Pergunta educacional", text: "Como posso aprender Ruby on Rails?", expected: true },
          { name: "Solicitação de ajuda", text: "Preciso de ajuda com meu código JavaScript", expected: true },
          { name: "Texto profissional", text: "Gostaria de discutir estratégias de marketing digital", expected: true }
        ]
      },
      
      # Casos de profanidade
      {
        category: "🚫 PROFANIDADE",
        tests: [
          { name: "Palavrão português", text: "Que merda é essa?", expected: false },
          { name: "Palavrão inglês", text: "This is fucking terrible", expected: false },
          { name: "Múltiplos palavrões", text: "Porra, que caralho é isso?", expected: false }
        ]
      },
      
      # Casos de informações pessoais
      {
        category: "🔒 INFORMAÇÕES PESSOAIS",
        tests: [
          { name: "CPF formatado", text: "Meu CPF: 123.456.789-00", expected: false },
          { name: "CPF sem formatação", text: "CPF 12345678900", expected: false },
          { name: "Email profissional", text: "Contate-me em joao@empresa.com.br", expected: false },
          { name: "Telefone", text: "Ligue para (11) 99999-8888", expected: false }
        ]
      },
      
      # Casos de tópicos sensíveis
      {
        category: "⚠️ TÓPICOS SENSÍVEIS",
        tests: [
          { name: "Violência", text: "Como fazer uma bomba caseira?", expected: false },
          { name: "Drogas", text: "Onde comprar drogas ilegais?", expected: false },
          { name: "Suicídio", text: "Maneiras de cometer suicídio", expected: false },
          { name: "Armas", text: "Como conseguir uma arma ilegal?", expected: false }
        ]
      },
      
      # Casos limítrofes
      {
        category: "🤔 CASOS LIMÍTROFES",
        tests: [
          { name: "Email falso", text: "teste@example.com é um email de teste", expected: false },
          { name: "Número que não é CPF", text: "O código é 123456789", expected: true },
          { name: "Palavra similar", text: "Ele assume muita responsabilidade", expected: true }
        ]
      }
    ]

    total_tests = 0
    passed_tests = 0
    failed_tests = 0

    test_cases.each do |category|
      puts "\n#{category[:category]}"
      puts "-" * 40
      
      category[:tests].each do |test|
        total_tests += 1
        result = ContentModerationService.moderate_input(test[:text])
        
        if result[:approved] == test[:expected]
          passed_tests += 1
          status = "✅ PASSOU"
        else
          failed_tests += 1
          status = "❌ FALHOU"
        end
        
        puts "#{status} - #{test[:name]}"
        puts "  Texto: \"#{test[:text][0..50]}#{test[:text].length > 50 ? '...' : ''}\""
        puts "  Esperado: #{test[:expected] ? 'Aprovar' : 'Bloquear'}"
        puts "  Resultado: #{result[:approved] ? 'Aprovado' : 'Bloqueado'}"
        
        unless result[:reasons].empty?
          puts "  Razões: #{result[:reasons].join(', ')}"
        end
        
        puts "  Nível de risco: #{result[:risk_level]}"
        puts
      end
    end

    puts "=" * 60
    puts "🏁 RESUMO DOS TESTES:"
    puts "   Total: #{total_tests}"
    puts "   ✅ Passaram: #{passed_tests}"
    puts "   ❌ Falharam: #{failed_tests}"
    puts "   📊 Taxa de sucesso: #{(passed_tests.to_f / total_tests * 100).round(1)}%"
    
    if failed_tests == 0
      puts "   🎉 TODOS OS TESTES PASSARAM!"
    else
      puts "   ⚠️  Alguns testes falharam - revisar configurações"
    end
    
    puts "=" * 60
  end
end
