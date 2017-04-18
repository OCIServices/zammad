# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Stats::TicketWaitingTime

  def self.generate(user)

    open_state_ids = Ticket::State.by_category(:open).pluck(:id)

    # get users groups
    group_ids = user.groups.map(&:id)

    own_waiting = Ticket.where(
      'owner_id = ? AND group_id IN (?) AND state_id IN (?) AND updated_at > ?', user.id, group_ids, open_state_ids, Time.zone.today
    )
    all_waiting = Ticket.where(
      'group_id IN (?) AND state_id IN (?) AND updated_at > ?', group_ids, open_state_ids, Time.zone.today
    )

    handling_time = calculate_average(own_waiting, Time.zone.today)
    if handling_time.positive?
      handling_time = (handling_time / 60).round
    end
    average_per_agent = calculate_average(all_waiting, Time.zone.today)
    if average_per_agent.positive?
      average_per_agent = (average_per_agent / 60).round
    end

    state   = 'supergood'
    percent = 0
    state   = if handling_time <= 60
                percent = handling_time.to_f / 60
                'supergood'
              elsif handling_time <= 60 * 4
                percent = (handling_time.to_f - 60) / (60 * 3)
                'good'
              elsif handling_time <= 60 * 8
                percent = (handling_time.to_f - 60 * 4) / (60 * 4)
                'ok'
              else
                percent = 1.00
                'bad'
              end

    {
      handling_time: handling_time,
      average_per_agent: average_per_agent,
      state: state,
      percent: percent,
    }
  end

  def self.average_state(result, _user_id)
    result
  end

  def self.calculate_average(tickets, start_time)
    average_time = 0
    count_time   = 0

    tickets.each { |ticket|
      ticket.articles.joins(:type).where('ticket_articles.created_at > ? AND ticket_articles.internal = ? AND ticket_article_types.communication = ?', start_time, false, true).each { |article|
        if article.sender.name == 'Customer'
          count_time = article.created_at.to_i
        else
          average_time += article.created_at.to_i - count_time
          count_time    = 0
        end
      }
    }

    average_time
  end
end
