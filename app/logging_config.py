import json
import logging
from datetime import datetime, timezone

class CustomJsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
        }

        extra_fields = [
            "status_code",
            "method",
            "path",
            "duration_ms",
        ]

        for field in extra_fields:
            if hasattr(record, field):
                log_record[field] = getattr(record, field)
                
        return json.dumps(log_record)

def configure_logging():
    handler = logging.StreamHandler()
    handler.setFormatter(CustomJsonFormatter())

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    root_logger.handlers.clear()
    root_logger.addHandler(handler)