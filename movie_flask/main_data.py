import pandas as pd
import ast

# Đọc dữ liệu từ hai file CSV (bỏ cột index nếu có trong file nguồn)
movies_df = pd.read_csv('tmdb_5000_movies.csv', index_col=0)  # Giả định cột 0 là index, bỏ nó
credits_df = pd.read_csv('tmdb_5000_credits.csv', index_col=0)  # Giả định cột 0 là index, bỏ nó

# Ghép hai dataframe dựa trên cột 'id' và 'movie_id'
movies_df = movies_df.rename(columns={'id': 'movie_id'})  # Đổi tên cột để ghép
merged_df = pd.merge(movies_df, credits_df, on='movie_id', how='inner')
print(movies_df)
merged_df = merged_df.drop_duplicates()

# Hàm trích xuất danh sách tên từ cột JSON
def extract_names(json_string, key='name'):
    try:
        data = ast.literal_eval(json_string)  # Chuyển string JSON thành list dict
        return [item[key] for item in data if key in item]
    except (ValueError, SyntaxError):
        return []

# Hàm trích xuất đạo diễn từ cột crew
def extract_director(crew_string):
    try:
        crew = ast.literal_eval(crew_string)
        for member in crew:
            if member.get('job') == 'Director':
                return member['name']
        return None
    except (ValueError, SyntaxError):
        return None

# Hàm chuyển danh sách thành chuỗi không có dấu ngoặc kép thừa
def list_to_string(lst):
    return str(lst).replace("'", '"') if lst else ''

# Trích xuất và xử lý các trường cần thiết
# Từ tmdb_5000_movies.csv
merged_df['genres'] = merged_df['genres'].apply(extract_names).apply(list_to_string)
merged_df['keywords'] = merged_df['keywords'].apply(extract_names).apply(list_to_string)
merged_df['spoken_languages'] = merged_df['spoken_languages'].apply(extract_names).apply(list_to_string)
merged_df['production_companies'] = merged_df['production_companies'].apply(extract_names).apply(list_to_string)
merged_df['production_countries'] = merged_df['production_countries'].apply(extract_names).apply(list_to_string)

# Từ tmdb_5000_credits.csv
merged_df['cast'] = merged_df['cast'].apply(lambda x: extract_names(x)[:3]).apply(list_to_string)
merged_df['crew'] = merged_df['crew'].apply(extract_names).apply(list_to_string)
merged_df['director'] = merged_df['crew'].apply(extract_director)

# Đổi tên cột 'title' thành 'title_x' và 'movie_id' thành 'id'
merged_df = merged_df.rename(columns={'title': 'title_x', 'movie_id': 'id'})

# Chọn các cột cần thiết
main_data_df = merged_df[[
    'budget', 'genres', 'homepage', 'id', 'keywords', 'original_language',
    'original_title', 'overview', 'popularity', 'production_companies',
    'production_countries', 'release_date', 'revenue', 'runtime',
    'spoken_languages', 'status', 'tagline', 'title_x', 'vote_average',
    'vote_count', 'cast', 'crew', 'director' 
]].copy()

# Xử lý giá trị NaN
main_data_df = main_data_df.fillna('')

# Lưu vào Main_data.csv (không thêm dấu ngoặc kép thừa)
main_data_df.to_csv('Main_data1.csv', index=False, quoting=0)  # 0 là csv.QUOTE_NONE
