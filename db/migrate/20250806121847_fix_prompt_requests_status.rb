class FixPromptRequestsStatus < ActiveRecord::Migration[7.1]
  def up
    # Corrige os status que foram salvos em português para as chaves corretas
    PromptRequest.where(status: 'concluída').update_all(status: 'completed')
    PromptRequest.where(status: 'pendente').update_all(status: 'pending')
    PromptRequest.where(status: 'falhou').update_all(status: 'failed')
  end

  def down
    # Reverte para as versões em português se necessário
    PromptRequest.where(status: 'completed').update_all(status: 'concluída')
    PromptRequest.where(status: 'pending').update_all(status: 'pendente')
    PromptRequest.where(status: 'failed').update_all(status: 'falhou')
  end
end
