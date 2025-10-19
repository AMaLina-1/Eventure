# Eventure

A web application that helps users discover **events** and **activities** happening in Hsinchu City.

# API Introduction

## Hshinchu City Government Web OpenAPI

- Introduction: Getting activity information from Hsinchu government.
- Request URL:
  
  ```
  https://webopenapi.hccg.gov.tw/v1/Activity?top=100
  ```
  
    - `top`: The number of records to return (Maximum = 100)
- Request Header:
    
    ```
    {
      "Accept": "application/json"
    }
    ```
    
- Response data
    
    After calling thie API, it will return the detail of the activities, and here are some infromation that might be helpful for our final project.
    
    - `pubunitname`: Name of issuing unit (發布單位名稱)
    - `subject`: Activity name (活動名稱)
    - `detailcontent`: Details (詳細內容)
    - `subjectclass`: Metadata-Subject Classification (詮釋資料-主題分類)
    - `serviceclass`: Metadata-Service Classification (詮釋資料-服務分類)
    - `voice`: Voice broadcast (語音播報)
    - `hostunit`: Organizer (主辦單位)
    - `joinunit`: Co-organizer (協辦單位)
    - `activitysdate`: Activity starting time (活動開始日期)
    - `activityedate`: Activity ending time (活動結束日期)
    - `activityplace`: Even location (活動地點)

    - **Issuing Unit**: Refers to the organization that hosts or announces activities.  
    - **Activity**: Represents the event or program users can attend. 
    - **Organizer**: The main entity responsible for hosting the event.  
    - **Co-organizer**: Additional entities that assist in hosting the event.  
    - **Location**: Where the event takes place.  
    - **Start Date** / **End Date**: The schedule of the event.  
    - **Details**: Additional information describing the event.  
    - **Classification**: Used to categorize events based on two types:
      - **Subject Classification**: Describes the theme or topic of the event (e.g., culture, education, sports).  
      - **Service Classification**: Describes the target audience or service category (e.g., general public, youth, elderly).
