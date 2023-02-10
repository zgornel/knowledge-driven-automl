function generate_test_data()
    # We assume a simplified Churn dataset, information split into three tables: Service, Subscription, Customers
    #
    # .---------------.  n:n  .----------.
    # |   Friends     |------>| Customer |
    # `---------------'       `----------'
    #                              ^ (1:n)
    #                              |
    # .---------------.       .--------------.
    # |   Service     |<----- | Subscription | (main table)
    # `---------------' (1:n) `--------------'
    #

    # Customers
    n = 3
    customer_id = 1:n
    age = rand(18:100, n)
    senior = age.>=60
    subscriptions = repeat([nothing],n)
    names = [randstring(5) for _ in 1:n]
    df_customers = DataFrame(id=customer_id, name=names, age=age, senior=senior, subscriptions=subscriptions)

    # Services
    SERVICES = [:internet_1Mbps, :internet_10Mbps, :internet_fiber]
    SPEED = [1, 10, 100]
    PRICES = [9.99, 19.99, 29.99]
    n = length(SERVICES)
    df_services = DataFrame(id=1:n, service=SERVICES, phone=repeat([false], n), security=repeat([false],n), speed=SPEED)

    # Subscriptions
    n = 10
    subscription_id = 1:n
    services = rand(df_services.service, n)
    amounts = [PRICES[findfirst(isequal(s), SERVICES)] for s in services]
    customers = rand(df_customers.name, n)
    df_subscriptions = DataFrame(id=1:n, service=services, customer=customers, amount=amounts)

    # Friends
    n = 100 # number of friends
    names = [randstring(5) for _ in 1:n]
    fof = rand(1:3, n)
    df_friends = DataFrame(id=1:n, name=names, fof=fof)

    # Build an entity graph with links and properties linking to a given list of tables
    mg = MetaDiGraph()
    add_vertices!(mg, 4)
    set_props!(mg, 1, Dict(:df_name=>:Services, :df => df_services))
    set_props!(mg, 2, Dict(:df_name=>:Customers, :df => df_customers))
    set_props!(mg, 3, Dict(:df_name=>:Subscriptions, :df => df_subscriptions))
    set_props!(mg, 4, Dict(:df_name=>:Friends, :df => df_friends))
    add_edge!(mg, 3, 1)  # subscriptions reference services
    add_edge!(mg, 3, 2)  # subscriptions reference customers
    add_edge!(mg, 4, 2)  # friends refence customers
    set_props!(mg, 3, 1, Dict(:link=>(:service, :service)))  # :service column in 'df_subscriptions' references :service column in 'df_services'
    set_props!(mg, 3, 2, Dict(:link=>(:customer, :name)))  # :customer column  in 'df_subscriptions' references :name column in 'df_customers'
    set_props!(mg, 4, 2, Dict(:link=>(:fof, :name)))  # :fof column  in 'df_friends' references :name column in 'df_customers'

    return mg, df_customers, df_services, df_subscriptions
end
