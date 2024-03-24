import csv
import tweepy

# Function to extract comments from a specific tweet
def extract_comments(api, tweet_id, max_comments=1000):
    replies = []
    for tweet in tweepy.Cursor(api.search, q=f"to:{tweet_id}", result_type="recent", timeout=999999).items(max_comments):
        if hasattr(tweet, "in_reply_to_status_id_str"):
            if tweet.in_reply_to_status_id_str == tweet_id:
                replies.append(tweet)
    return replies

# Function to save comments to a CSV file
def save_comments_to_csv(comments, filename):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        csv_writer = csv.DictWriter(f, fieldnames=("user", "text"))
        csv_writer.writeheader()
        for comment in comments:
            row = {
                "user": comment.user.screen_name,
                "text": comment.text.replace("\n", " ")
            }
            csv_writer.writerow(row)

# Function to process multiple posts and save comments to CSV files
def process_posts(api, post_ids, max_comments=1000):
    for post_id in post_ids:
        print(f"Processing post: {post_id}")
        
        # Extract comments from the post
        comments = extract_comments(api, post_id, max_comments)
        
        # Generate the CSV filename based on the post ID
        filename = f"replies_{post_id}.csv"
        
        # Save comments to the CSV file
        save_comments_to_csv(comments, filename)
        
        print(f"Comments saved to {filename}")

# Get credentials from developer.twitter.com
auth = tweepy.OAuthHandler("API Key", "API Secret")
auth.set_access_token("Access Token", "Access Token Secret")
api = tweepy.API(auth)

# List of post IDs to process
post_ids = [
    "1234567890",
    "9876543210",
    "1122334455"
]

# Maximum number of comments to retrieve per post
max_comments = 1000

# Process the posts and save comments to CSV files
process_posts(api, post_ids, max_comments)
