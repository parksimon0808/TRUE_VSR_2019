import pandas as pd

# process 2008-2019 data

for year in range(2008, 2020):
    df = pd.read_csv('./raw_data/metro_data_%d.csv' % year, encoding='utf-8')
    df.columns = ['날짜', '역번호', '역명', '구분', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '00']

    for col in df.columns:
        df[col] = df[col].astype('str').str.replace(' ', '')
        df[col] = df[col].astype('str').str.replace(',', '')

    df = df.drop(columns=['날짜', '역명'], axis=1)

    station_numbers = df['역번호'].unique().tolist()

    departure = df.loc[df['구분'] == '승차']
    departure = departure.drop(columns=['구분'], axis=1)

    arrival = df.loc[df['구분'] == '하차']
    arrival = arrival.drop(columns=['구분'], axis=1)

    for number in station_numbers:
        data = departure.loc[departure['역번호'] == number]
        data = data.drop(columns='역번호', axis=1)
        data.to_csv('./data/departure/%s_%d.csv' % (number, year), index=False)

        data = arrival.loc[arrival['역번호'] == number]
        data = data.drop(columns='역번호', axis=1)
        data.to_csv('./data/arrival/%s_%d.csv' % (number, year), index=False)
