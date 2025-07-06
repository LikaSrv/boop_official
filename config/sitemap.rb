# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.myboop.fr" # Remplace par ton vrai domaine

SitemapGenerator::Sitemap.create do
  # Pages principales
  add root_path, priority: 1.0, changefreq: 'daily'
  add about_path, changefreq: 'monthly'
  add contact_path, changefreq: 'monthly'
  add terms_path, changefreq: 'yearly'
  add privacy_policy_path, changefreq: 'yearly'
  add why_boop_pro_path, changefreq: 'monthly'
  add why_boop_path, changefreq: 'monthly'
  add explore_path, changefreq: 'daily'

  # Tous les professionnels
  Professional.find_each do |pro|
    add professional_path(pro), lastmod: pro.updated_at
  end

  # Tous les animaux à l'adoption (si tu as un modèle Animal)
  if defined?(Animal)
    Animal.find_each do |animal|
      add animal_path(animal), lastmod: animal.updated_at
    end
  end

  # Tous les posts/articles (si tu as un blog)
  if defined?(Post)
    Post.find_each do |post|
      add post_path(post), lastmod: post.updated_at
    end
  end

  Pricing.find_each do |pricing|
    add pricing_path(pricing), lastmod: pricing.updated_at
  end
end
