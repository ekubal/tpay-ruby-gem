tpay-ruby-gem
===================

This is a Ruby Gem for tpay.com API. It allows you to create a pay URL simply and validate webhook (payment notification). It's super easy to use and saves you some code. 

## Instalation

```
gem install tpay
```

or add it to your `Gemfile`:

```
gem 'tpay'
```

## Usage

### Configuration

First you have to configure gem using your details form tpay.com panel. You need your Receiver ID and Secret Code. If you're using Rails you can create initializer file `config/initializers/tpay.rb'`:

```ruby
Rails.application.config.before_initialize do
	Tpay.id = 14090
	Tpay.security_code = 'EAoycw18x2tVo4OU'
end
```

or just set `id` and `security_code` before first usage.

### Sample code (Rails)

The basic usage of tpay API is redirecting to payment page with some arguments and receiving webhooks (payment notifications).
First read the documentation which you can find [here](https://docs.tpay.com/).

#### Creating pay URL

If you want to create url to redirect user to payment page just call `pay_url` with parameters. [Here](https://docs.tpay.com/) you can find list of params. Skip `id` attribute.  

```ruby
def pay
	url = Tpay.pay_url(
		{
			:kwota => 1,
			:opis => 'Opis transakcji',
			:crc => '124',
			:online => 1,
			:wyn_url => url_for( controller: 'transactions', action: 'webhook', host: 'http://myapp.com'),
			:pow_url => url_for( controller: 'site', action: 'index', host: 'http://myapp.com'),
			:pow_url_blad => url_for( controller: 'site', action: 'index', host: 'http://myapp.com'),
		}
	)
	redirect_to url
end
```

#### Validate webhook

To validate webhook just call `webhook_valid?`. First argument is params hash from POST request, second is IP address of host sending request.

```ruby
def webhook
	if Tpay.webhook_valid?(params, request.ip)
		#process transaction
		respond_to do |format|
			format.html { render :text => "TRUE" }
		end
	else
		render :status => 404
	end
end
```

## Important!!!

* Enable Test Mode in your tpay.com panel.
* You can send test webhooks form your tpay.com panel

## Thanks

Adam Mazur - transferuj-ruby-gem author


## Licence

Copyright (c) 2018 Jakub Lasek, released under the MIT license

