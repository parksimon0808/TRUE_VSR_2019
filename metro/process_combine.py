import pandas as pd

df = pd.read_csv('./raw_data/metro_data_2019.csv', encoding='utf-8')
df.columns = ['날짜', '역번호', '역명', '구분', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '00']
df = df.drop(columns=['날짜', '역명'], axis=1)

station_numbers = df['역번호'].unique().tolist()

for station in station_numbers:
    
    departure = pd.DataFrame()
    
    for year in range(2008, 2018):
        try:
            new_departure = pd.read_csv('./data/departure/%d_%d.csv' % (station, year), encoding='utf-8')
            num_rows = len(new_departure.index)
            #if (num_rows < 365):
                #print('station %d has %d data points in year %d' % (station, num_rows, year))
            departure = pd.concat([departure, new_departure], axis=0, ignore_index=True)
        except:
            print('')
            #print('station %d does not have data in year %d' % (station, year))

    departure.to_csv('./data/departure/%s_2008_to_2017.csv' % station, index=False)
