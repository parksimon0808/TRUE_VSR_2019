import pandas as pd

# load the list of station numbers from the raw data of the most recent year
df = pd.read_csv('./raw_data/metro_data_2019.csv', encoding='utf-8')
df.columns = ['날짜', '역번호', '역명', '구분', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '00']
df = df.drop(columns=['날짜', '역명'], axis=1)
station_numbers = df['역번호'].unique().tolist()

# combine the data from different calender years for each station
for station in station_numbers:
    
    # process the departure data
    departure = pd.DataFrame()
    for year in range(2008, 2018):
        try:
            # read the data from the next year
            new_departure = pd.read_csv('./data/departure/%d_%d.csv' % (station, year), encoding='utf-8')
            num_rows = len(new_departure.index)
                
            # combine the data with the data from previous years
            departure = pd.concat([departure, new_departure], axis=0, ignore_index=True)
        except:
            print('')
    departure.to_csv('./data/departure/%s_2008_to_2017.csv' % station, index=False)
    
    # process the arrival data
    arrival = pd.DataFrame()
    for year in range(2008, 2018):
        try:
            # read the data from the next year
            new_arrival = pd.read_csv('./data/arrival/%d_%d.csv' % (station, year), encoding='utf-8')
            num_rows = len(new_arrival.index)
                
            # combine the data with the data from previous years
            arrival = pd.concat([arrival, new_arrival], axis=0, ignore_index=True)
        except:
            print('')
    arrival.to_csv('./data/arrival/%s_2008_to_2017.csv' % station, index=False)

