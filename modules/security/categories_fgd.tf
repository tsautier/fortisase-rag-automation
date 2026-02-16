locals {

  # Set fgd restricted categories to block
  fgd_restricted_categories = [
    for category in local.fgd_categories_all_monitor : (
      contains(var.webfilter_restricted_categories, category.category.primary_key)
      ? merge(category, { action = "block" })
      : category
    )
  ]

  # All fgd categories are set to monitor,
  # except the ones blocked by default, considered unsecure: 
  # "Malicious Websites", "Phishing", etc.
  fgd_categories_all_monitor = [
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Social Networking"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Political Organizations"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Gambling"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Drug Abuse"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Hacking"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Illegal or Unethical"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Discrimination"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Explicit Violence"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Extremist Groups"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Proxy Avoidance"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Plagiarism"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Child Sexual Abuse"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Terrorism"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Crypto Mining"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Potentially Unwanted Program"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Alternative Beliefs"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Abortion"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Other Adult Materials"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Advocacy Organizations"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Nudity and Risque"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Pornography"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Dating"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Weapons (Sales)"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Marijuana"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Sex Education"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Alcohol"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Tobacco"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Lingerie and Swimsuit"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Sports Hunting and War Games"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Freeware and Software Downloads"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "File Sharing and Storage"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Streaming Media and Download"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Peer-to-peer File Sharing"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Internet Radio and TV"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Internet Telephony"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Malicious Websites"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Phishing"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Spam URLs"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Dynamic DNS"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Newly Observed Domain"
      },
      warning_duration = null
    },
    {
      action = "block",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Newly Registered Domain"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Advertising"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Brokerage and Trading"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Games"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Web-based Email"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Entertainment"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Arts and Culture"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Education"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Health and Wellness"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Job Search"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Medicine"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "News and Media"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Reference"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Global Religion"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Shopping"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Society and Lifestyles"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Sports"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Travel"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Personal Vehicles"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Dynamic Content"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Meaningless Content"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Folklore"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Web Chat"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Instant Messaging"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Newsgroups and Message Boards"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Digital Postcards"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Child Education"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Real Estate"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Restaurant and Dining"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Personal Websites and Blogs"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Content Servers"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Domain Parking"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Personal Privacy"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Auction"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Finance and Banking"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Search Engines and Portals"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "General Organizations"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Business"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Information and Computer Security"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Government and Legal Organizations"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Information Technology"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Armed Forces"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Web Hosting"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Secure Websites"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Web-based Applications"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Charitable Organizations"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Remote Access"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Web Analytics"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Online Meeting"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "URL Shortening"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Artificial Intelligence Technology"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Cryptocurrency"
      },
      warning_duration = null
    },
    {
      action = "monitor",
      category = {
        datasource  = "security/fortiguard-categories",
        primary_key = "Unrated"
      },
      warning_duration = null
    }
  ]
}
