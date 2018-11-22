CREATE TABLE PERSON (
    id uuid PRIMARY KEY,
    account_id uuid not null REFERENCES account (id),
    data jsonb NOT NULL
);
