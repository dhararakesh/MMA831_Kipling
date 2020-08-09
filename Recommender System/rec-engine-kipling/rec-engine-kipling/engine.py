#import necessary packages
from sqlalchemy import create_engine
import pandas as pd
from sqlalchemy import select

import sqlalchemy as db
import seaborn as sns
from flask import Flask, render_template, request

#be837f2e0152a208d4386f4126d5bd7c   
def get_recommendations(first_name):
    #print(first_name)
    import os
    os.getcwd()
    #first_name = '8c9ca7a5718a991b4f765b8c3d569b85'
    #import the table (as specified above)
    # olist_items_tbl = pd.read_csv("../../../dataset/olist_order_items_dataset.csv")
    # olist_items_tbl.head()
    # #we just need the ids
    # order_prod_id = olist_items_tbl[['order_id', 'product_id']]
    # order_prod_id.head()
    
    #import recommendations input
    recomm_input = pd.read_csv("recommendation_inputs.csv")
    recomm_input.columns
    recomm_input.head()
    

    segment = 0;
    #get the segment the customer belongs to
    for index, row in recomm_input.iterrows():
        if first_name == row['customer_unique_id']:
            segment = recomm_input.loc[index].at['segment']
            
    #get the instances that belong to the same customer segment
    final_df = recomm_input[recomm_input['segment'] == segment]
    final_df.head(100) 
    #we only need 'customer_unique_id', 'product_id', 'avg_review_score'
    final_df = final_df[['customer_unique_id', 'product_id', 'avg_review_score']]
    
    #get the product names from display later
    product_level = pd.read_csv("../../../831_final_product_level_dataset.csv")
    product_level.head()
    #we only need product_id and avg_review_score
    # prod_avg_review = product_level[['product_id','avg_review_score']]
    # prod_avg_review.head()
    
    prod_name = product_level[['product_id','product_category_name_english']]
    prod_name.head()
    
    #now we want customer_id and order_id - orders tbl
    # olist_orders_tbl = pd.read_csv("../../../dataset/olist_orders_dataset.csv")
    # olist_orders_tbl.head()
    # #we only need order_id and customer_id
    # cust_order_id = olist_orders_tbl[['order_id','customer_id']]
    # cust_order_id.head()
    
    
    # #Now we merge on order_id, cust_id and product_id
    # order_prod_merge = pd.merge(order_prod_id, prod_avg_review, left_on='product_id', right_on = 'product_id', how='outer')
    # order_prod_merge.head(100)
    # order_cust_merge = pd.merge(cust_order_id, order_prod_merge, left_on='order_id', right_on = 'order_id', how='outer')
    # order_cust_merge.head(100)
    
    #drop order_id to get final dataset for recco sys
    #final_df = order_cust_merge.drop(columns='order_id')
    
    #for testing START
    #result = final_df.sort_values(['customer_id'], ascending=True)
    #test = result.head(10000)
    #for testing END
    
    import surprise
    reader = surprise.Reader(rating_scale=(1, 5))
    data = surprise.Dataset.load_from_df(final_df, reader)
    #type(data)
    
    from surprise import SVD
    from surprise import Dataset
    from surprise import accuracy
    from surprise.model_selection import train_test_split
    from surprise import KNNBaseline, KNNBasic, KNNWithMeans, KNNWithZScore, SVD
    from surprise.prediction_algorithms.knns import KNNBasic
    trainset, testset = train_test_split(data, test_size=0.33, random_state=42)
    #type(trainset)
    
    # sim_options = {'name': 'MSD',
    #            'user_based': True  # compute  similarities between items
    #            }
    # #recommender start
    # algo = KNNBasic(k=10, min_k=4, sim_options=sim_options)
    algo = SVD()
    algo.fit(trainset)
    predictions = algo.test(testset)
    accuracy.rmse(predictions)
    
    from collections import defaultdict
    pred = []
    #for that particular user, get the prediction rating for each item 
    #because that user may not be in the test set
    for index_u, row_u in final_df.iterrows():
        if row_u['customer_unique_id'] == first_name:
            for index_p, row_p in prod_name.iterrows():
                pred.append(algo.predict(row_u['customer_unique_id'], row_p['product_id']))

    def get_top_n(predictions, n=5):
        """Return the top-N recommendation for each user from a set of predictions.
    
        Args:
            predictions(list of Prediction objects): The list of predictions, as
                returned by the test method of an algorithm.
            n(int): The number of recommendation to output for each user. Default
                is 10.
    
        Returns:
        A dict where keys are user (raw) ids and values are lists of tuples:
            [(raw item id, rating estimation), ...] of size n.
        """
    
        # First map the predictions to each user.
        top_n = defaultdict(list)
        for uid, iid, true_r, est, _ in predictions:
            top_n[uid].append((iid, est))
    
        # Then sort the predictions for each user and retrieve the k highest ones.
        for uid, user_ratings in top_n.items():
            user_ratings.sort(key=lambda x: x[1], reverse=True)
            top_n[uid] = user_ratings[:n]
    
        return top_n
    
    top_n = get_top_n(predictions, n=5)
    top_n_user = get_top_n(pred, n=5)
    # Print the recommended items for each user
    column_names = ["uid", "iid"]
    df = pd.DataFrame(columns = column_names)
    df_agg = pd.DataFrame(columns = column_names)
    prod_name_merge = pd.DataFrame()
    df_top_prod = pd.DataFrame()
    #message = 'Hello %s have fun learning python <br/> <a href="/">Back Home</a>' % (first_name)
    for uid, user_ratings in top_n.items():
        #uid, user_ratings in user_ratings]
        # if uid == first_name:
        #     for iid, rating in top_n[uid]:
        #         df = df.append({'uid' : uid , 'iid' : iid} , ignore_index=True);
       
        for iid, rating in top_n[uid]:     
           df_agg = df_agg.append({'uid' : uid , 'iid' : iid} , ignore_index=True); 
           
    for uid, user_ratings in top_n_user.items():
        #uid, user_ratings in user_ratings]
        for iid, rating in top_n_user[uid]:
            df = df.append({'uid' : uid , 'iid' : iid} , ignore_index=True);
  
    df_agg = pd.merge(df_agg, prod_name, left_on='iid', right_on = 'product_id', how='inner')
    df_agg.head(100)            
    prod_name_merge = pd.merge(df, prod_name, left_on='iid', right_on = 'product_id', how='inner')
    prod_name_merge.head(100)            
    #013ee64977aaa6b2b25475095162e0e9
    df_top_prod = df_agg['product_id'].value_counts().rename_axis('product_id').reset_index(name='count')
    df_top_prod = df_top_prod.head(5)
    df_top_prod = pd.merge(df_top_prod, prod_name, left_on='product_id', right_on = 'product_id', how='inner')
    return render_template('test.html', variable1=200, variable2=prod_name_merge.to_json(orient="table"), variable3=df_top_prod.to_json(orient="table"))















