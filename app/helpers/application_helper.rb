module ApplicationHelper
  # Formata data/hora para o timezone de Brasília
  def format_brasilia_time(datetime, format = :short)
    return '' unless datetime
    
    brasilia_time = datetime.in_time_zone("America/Sao_Paulo")
    l(brasilia_time, format: format)
  end

  # Formata com indicação explícita do fuso horário de Brasília
  def format_brasilia_time_with_zone(datetime)
    return '' unless datetime
    
    brasilia_time = datetime.in_time_zone("America/Sao_Paulo")
    l(brasilia_time, format: :with_zone)
  end

  # Formata apenas a data
  def format_brasilia_date(datetime)
    return '' unless datetime
    
    brasilia_time = datetime.in_time_zone("America/Sao_Paulo")
    l(brasilia_time.to_date, format: :short)
  end

  # Helper para mostrar tempo relativo (ex: "há 2 horas")
  def time_ago_in_brasilia(datetime)
    return '' unless datetime
    
    brasilia_time = datetime.in_time_zone("America/Sao_Paulo")
    time_ago_in_words(brasilia_time) + " atrás"
  end
end
