<?php
return ['enabled'=>(bool)env('FCM_ENABLED',false),'project_id'=>env('FCM_PROJECT_ID'),'credentials_path'=>env('FCM_CREDENTIALS_PATH'),'max_attempts'=>(int)env('FCM_MAX_ATTEMPTS',3)];
