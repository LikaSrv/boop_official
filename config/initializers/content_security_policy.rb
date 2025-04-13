# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self, :https
#   policy.script_src :self, :https, 'https://js.stripe.com'
#   policy.style_src :self, :https
#   policy.img_src :self, :https, :data
#   policy.font_src :self, :https, :data
#   policy.object_src :none
#   policy.frame_src 'https://js.stripe.com', 'https://hooks.stripe.com'
#   policy.connect_src :self, 'https://api.stripe.com'
#   policy.img_src :self, :https, :data, 'https://ucarecdn.com', 'https://api.brevo.com'
#   policy.frame_src 'https://js.stripe.com', 'https://hooks.stripe.com', 'https://webhooks.brevo.com'
#   # policy.report_uri "/csp-violation-report-endpoint"
# end


# Generate session nonces for permitted importmap, inline scripts, and inline styles.
# Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

