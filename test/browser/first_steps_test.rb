# encoding: utf-8
require 'browser_test_helper'

class FirstStepsTest < TestCase

  def test_basic
    agent    = "bob.smith_#{rand(99_999_999)}"
    customer = "customer.smith_#{rand(99_999_999)}"

    @browser = browser_instance
    login(
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all()
    click(
      css: '.active.content .tab[data-area="first-steps-widgets"]',
    )
    watch_for(
      css:   '.active.content',
      value: 'Configuration',
    )

    # invite agent
    click(
      css: '.active.content .js-inviteAgent',
    )
    sleep 4
    set(
      css: '.modal [name="firstname"]',
      value: 'Bob',
    )
    set(
      css: '.modal [name="lastname"]',
      value: 'Smith',
    )
    set(
      css: '.modal [name="email"]',
      value: "#{agent}@example.com",
    )
    check(
      css: '.modal [name="group_ids"]',
    )
    click(
      css: '.modal button.btn.btn--primary',
    )
    watch_for(
      css:   'body div.modal',
      value: 'Sending',
    )
    watch_for_disappear(
      css:   'body div.modal',
      value: 'Sending',
    )

    # invite customer
    click(
      css: '.active.content .js-inviteCustomer',
    )
    sleep 4
    set(
      css: '.modal [name="firstname"]',
      value: 'Client',
    )
    set(
      css: '.modal [name="lastname"]',
      value: 'Smith',
    )
    set(
      css: '.modal [name="email"]',
      value: "#{customer}@example.com",
    )
    set(
      css: '.modal [data-name="note"]',
      value: 'some note',
    )
    click(
      css: '.modal button.btn.btn--primary',
    )
    watch_for(
      css:   'body div.modal',
      value: 'Sending',
    )
    watch_for_disappear(
      css:   'body div.modal',
      value: 'Sending',
    )

    # test ticket
    click(
      css: '.active.content .js-testTicket',
    )
    watch_for(
      css:   'body div.modal',
      value: 'A Test Ticket has been created',
    )
    click(
      css: '.modal .modal-body',
    )
    watch_for_disappear(
      css:   'body div.modal',
      value: 'Test Ticket',
    )
    execute(
      js: '$(".active.content .sidebar").show()',
    )
    watch_for(
      css:     '.active.content .js-activityContent',
      value:   'Nicole Braun created Article for Test Ticket!',
      timeout: 35,
    )

    # check update
    click(
      css: '.active.content a[href="#channels/form"]',
    )
    sleep 2
    switch(
      css: '#content .js-formSetting',
      type: 'on',
    )
    sleep 2
    click(
      css: '#navigation a[href="#dashboard"]',
    )
    hit = false
    (1..38).each {
      next if !@browser.find_elements(css: '.active.content a[href="#channels/form"].todo.is-done')[0]
      hit = true
      break
    }
    assert(hit)

  end

end
