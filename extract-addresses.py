import csv
import tweepy

# Get credentials at developer.twitter.com
auth = tweepy.OAuthHandler('API Key', 'API Secret')
auth.set_access_token('Access Token', 'Access Token Secret')
api = tweepy.API(auth)

# Update these for whatever tweet you want to process replies to
name = 'patrick_oshag'
tweet_id = '1101551802930077696'

replies = []
for tweet in tweepy.Cursor(api.search, q='to:' + name, result_type='recent', timeout=999999).items(1000):
    if hasattr(tweet, 'in_reply_to_status_id_str'):
        if tweet.in_reply_to_status_id_str == tweet_id:
            replies.append(tweet)

with open('replies_clean.csv', 'w', newline='') as f:
    csv_writer = csv.DictWriter(f, fieldnames=('user', 'text'))
    csv_writer.writeheader()
    for tweet in replies:
        row = {
            'user': tweet.user.screen_name,
            'text': tweet.text.encode('ascii', 'ignore').decode('ascii').replace('\n', ' ')
        }
        csv_writer.writerow(row)
