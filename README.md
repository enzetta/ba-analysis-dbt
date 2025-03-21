# Twitter Political Discourse Analysis (dbt)

## Overview

This project is part of a **Bachelor's Thesis** analyzing **political discourse on Twitter** in Germany between **2020 and 2021**. The analysis focuses on:

- The role of politicians and politically engaged users in shaping discourse.
- The interaction dynamics between different political factions.
- The categorization of hashtags into political topics.
- The spread of political messaging across different user groups.
- Analysis of toxicity and sentiment in political discourse.

The project uses **dbt (Data Build Tool)** for **data modeling and transformation** to clean, structure, and analyze Twitter data.

> **Note**: This project was developed with assistance from Large Language Models (LLMs)  including OpenAI GPT and Anthropic Claude to help with code generation, documentation, and best practices in data processing.

---

## **Why dbt?**

This project uses dbt (Data Build Tool) instead of running individual scripts for several important reasons:

### **1. Data Pipeline Management**
- **Dependency Management**: dbt automatically handles the order of operations, ensuring each step runs only after its dependencies are complete
- **Incremental Processing**: Only processes new or changed data, making the pipeline efficient
- **Version Control**: All data transformations are version-controlled alongside the code

### **2. Data Quality**
- **Built-in Testing**: dbt provides a framework for testing data quality (e.g., checking for null values, unique keys), although I didn't implemented any tests in this project.
- **Documentation**: Automatically generates documentation for all tables and their relationships
- **Consistency**: Ensures consistent naming and structure across all transformations

### **3. Collaboration & Reproducibility**
- **Standardized Format**: Uses SQL, a widely understood language for data manipulation
- **Modular Design**: Breaks down complex transformations into reusable components
- **Clear Lineage**: Shows how data flows from raw sources to final analysis

### **4. Big Data Considerations**
- **Efficient Processing**: Optimizes queries for BigQuery, handling large-scale data efficiently
- **Cost Management**: Helps control BigQuery costs through optimized transformations
- **Scalability**: Easily handles growing data volumes without rewriting code

### **5. Academic Research Benefits**
- **Transparency**: Makes the research process transparent and reproducible
- **Documentation**: Automatically generates documentation explaining each transformation
- **Maintainability**: Makes it easier to modify or extend the analysis as research evolves

---

## **Project Structure**

This dbt project is structured as follows:

```
├── models/
│   ├── 00_source/        # Raw Twitter and politician data sources
│   ├── 00_source_python/ # Python-generated source tables
│   ├── 10_staging/       # Intermediate transformations
│   ├── 20_curated/       # Final curated models for analysis
│   ├── 30_stats/         # Statistical analysis models
│   ├── 30_network_analysis/ # Network analysis models
│   ├── 30_backup/        # Backup models
│   ├── tests/            # Data quality tests
│   ├── macros/           # Custom dbt macros
│── seeds/                # Pre-loaded reference data
│── snapshots/            # Historical snapshots
│── dbt_project.yml       # dbt configuration
│── profiles.yml          # Database connection settings
│── requirements.txt      # Python dependencies
└── README.md             # This file
```

---

## **Detailed Table Descriptions**

### **Source Tables (`models/00_source/`)**

#### **1. Users Table**
- Contains cleaned and typed information from raw Twitter users
- Key columns:
  - `user_id`: Unique identifier
  - `screen_name`: Twitter username (lowercase)
  - `name`: Display name
  - `description`: Profile description
  - `location`: User location
  - `verified`: Account verification status
  - `followers_count`: Number of followers
  - `friends_count`: Number of users being followed
  - `statuses_count`: Total number of tweets
  - `created_at`: Account creation timestamp

#### **2. Interactions Table**
- Contains cleaned and typed data from raw tweets
- Key columns:
  - `tweet_id`: Unique identifier
  - `user_id`: Author's user ID
  - `type`: Interaction type (tweet, retweet, etc.)
  - `hashtags`: Array of hashtags used
  - `mentioned_ids`: Array of mentioned user IDs
  - `text`: Cleaned tweet text
  - `created_at`: Tweet creation timestamp
  - `retweet_count`: Number of retweets
  - `favourite_count`: Number of likes

#### **3. Political Users Table (`ext_epi_netz_de`)**
- Contains information about German politicians
- Key columns:
  - `user_id`: Twitter user ID
  - `official_name`: Full name
  - `party`: Political party affiliation
  - `region`: Geographic region
  - `institution`: Political institution
  - `twitter_handle`: Twitter username
  - `wikidata_id`: Wikidata entity ID

#### **4. Hashtag Categorization Table**
- Contains categorized hashtag usage statistics
- Key columns:
  - `hashtag`: The hashtag being analyzed
  - `usage_count`: Total usage count
  - `unique_users`: Number of unique users
  - `politician_users`: Number of politicians using it
  - `categories`: Assigned categories (semicolon-separated)
  - `confidence`: Categorization confidence score

### **Python Source Tables (`models/00_source_python/`)**

> **Note**: While these tables are placed in the source layer, they are actually derived from the project's curated data. They were created by running Python scripts on the `tweets_relevant_all` table to perform sentiment and network analysis. The process took approximately 4 days to complete due to the large volume of data and the complexity of the analysis.

#### **1. Tweet Sentiment Analysis**
- Contains sentiment and toxicity analysis of tweets
- Key columns:
  - `tweet_id`: Unique identifier
  - `sentiment`: Sentiment classification
  - `positive_probability`: Probability of positive sentiment
  - `negative_probability`: Probability of negative sentiment
  - `toxicity_label`: Toxicity classification
  - `toxicity_score`: Toxicity score
- **Creation Process**: 
  - Generated from `tweets_relevant_all` using ML models
  - Analyzes sentiment and toxicity of political discourse
  - Used for understanding the tone and quality of political interactions

#### **2. Network Metrics**
- Contains network analysis metrics
- Key columns:
  - `month_start`: Analysis period start
  - `nodes`: Number of nodes in network
  - `edges`: Number of edges in network
  - `density`: Network density
  - `modularity`: Network modularity
  - `assortativity`: Network assortativity
  - `network_avg_toxicity`: Average toxicity in network
- **Creation Process**:
  - Generated from interaction patterns in `tweets_relevant_all`
  - Computes complex network metrics using Python libraries
  - Used for understanding the structure of political discourse networks

### **Staging Tables (`models/10_staging/`)**

#### **1. Interactions with Referrers**
- Enhanced version of interactions table
- Adds `refers_to_user_id` for referenced tweets
- Includes all original interaction data

#### **2. Political Users**
- Matches Twitter users with known German politicians
- Combines user information with political metadata
- Includes verification through Twitter handles and user IDs

#### **3. Political Hashtags Count**
- Aggregated statistics about hashtag usage
- Focuses on hashtags used by politicians
- Includes temporal usage data

### **Curated Tables (`models/20_curated/`)**

#### **1. Network Models**
- `network_all`: Comprehensive network of relationships
  - Includes user-to-user, user-to-hashtag, and hashtag co-occurrences
  - Contains toxicity metrics and interaction weights
- `network_all_hashtags_users`: Filtered view of hashtag-user connections
- `network_all_users`: User-to-user connections only
- `network_climate_users`: Climate-related discussion network
- `network_migration_users`: Migration-related discussion network

#### **2. Relevant Tweets**
- `tweets_relevant_all`: All politically relevant tweets
- `tweets_relevant_climate`: Climate-related tweets
- `tweets_relevant_migration`: Migration-related tweets
- `tweets_relevant_with_predictions`: Tweets with sentiment and toxicity predictions

#### **3. Hashtag Categories**
- `hashtags_categories_exploded`: Individual hashtag-category pairs
- `hashtags_categories_aggregated`: Aggregated categories per hashtag

### **Statistical Analysis Tables (`models/30_stats/`)**

#### **1. Toxicity Analysis**
- `toxicity_statistics`: Overall toxicity statistics
- `toxicity_distribution_users`: Toxicity distribution across users
- `toxicity_distribution_users_by_party`: Toxicity by political party
- `toxicity_distribution_tweets`: Toxicity distribution across tweets
- `toxicity_by_party`: Party-level toxicity metrics
- `most_toxic_accounts`: Top toxic accounts
- `most_toxic_tweets`: Most toxic tweets

#### **2. User Analysis**
- `distribution_users_type`: Distribution of user types
- `distribution_tweets_by_user_type`: Tweet distribution by user type

#### **3. Network Analysis**
- `network_gephi`: Network data formatted for Gephi visualization

---

## **Installation & Setup**

### **1. Prerequisites**
- Python 3.8 or higher
- Google Cloud Platform account with BigQuery access
- Git

### **2. Install Required Dependencies**
```sh
# Create and activate virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### **3. Set Up Google Cloud Credentials**
1. Create a service account in Google Cloud Console
2. Download the service account key file
3. Place it in `.secrets/service-account.json`
4. Set the environment variable:
```sh
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account.json
```

### **4. Configure dbt**
Edit `profiles.yml` with your BigQuery settings:
```yaml
ba_twitter_analysis:
  outputs:
    dev:
      type: bigquery
      project: your-google-cloud-project
      dataset: twitter_analysis
      keyfile: .secrets/service-account.json
      location: EU
      threads: 4
      priority: interactive
  target: dev
```

### **5. Initialize dbt**
```sh
# Install dbt dependencies
dbt deps

# Load seed data
dbt seed
```

---

## **Usage & Running dbt Models**

### **1. Run All Models**
```sh
dbt build
```

### **2. Run Specific Models**
```sh
# Run a specific model and its dependencies
dbt run --models staging.political_users+

# Run models in a specific directory
dbt run --models curated.*
```

### **3. Full Refresh**
```sh
dbt build --full-refresh
```

### **4. Generate Documentation**
```sh
dbt docs generate
dbt docs serve
```

### **5. Run Tests**
```sh
dbt test
```

---

## **Code Quality & Linting**

This project follows standard SQL best practices and naming conventions. All SQL files are organized in a clear, hierarchical structure:

- `00_source/`: Raw data sources
- `00_source_python/`: Python-generated source tables
- `10_staging/`: Intermediate transformations
- `20_curated/`: Final curated models
- `30_stats/`: Statistical analysis
- `30_network_analysis/`: Network analysis
- `30_backup/`: Backup models

Each SQL file follows a consistent naming convention and includes clear documentation of its purpose and dependencies.

---

## **License & Acknowledgements**
This project is part of a **Bachelor's Thesis** analyzing social media polarization. Data sources include:
- Zenodo's Twitter dataset
- Publicly available information on German politicians
- EPI network data
