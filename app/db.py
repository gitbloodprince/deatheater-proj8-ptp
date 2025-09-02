from sqlalchemy import create_engine, Column, Integer, String, Table, MetaData
from sqlalchemy.orm import sessionmaker

# Example connection string for local SQLite (for testing)
DATABASE_URL = "sqlite:///project8.db"

engine = create_engine(DATABASE_URL, echo=True)
metadata = MetaData()

entries_table = Table(
    'entries', metadata,
    Column('id', Integer, primary_key=True),
    Column('name', String),
    Column('email', String)
)

metadata.create_all(engine)
SessionLocal = sessionmaker(bind=engine)
