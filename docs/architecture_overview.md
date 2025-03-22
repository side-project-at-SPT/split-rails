# Split Game Architecture Documentation

This documentation provides a comprehensive overview of the Split game application architecture through a series of Mermaid diagrams. Each diagram focuses on a specific aspect of the system.

## Table of Contents

1. [Models and Relationships](models.md) - Class diagram showing the data models and their relationships
2. [System Architecture](system_architecture.md) - Overview of the system components and how they interact
3. [Game Flow](game_flow.md) - Sequence diagram illustrating the flow of a typical game session
4. [Game States](game_states.md) - State diagram showing the different states a game can be in
5. [API Endpoints](api_endpoints.md) - Structure of the API endpoints for interacting with the system
6. [Real-time Communication Channels](realtime_channels.md) - WebSocket channels for real-time updates

## About the Split Game

Split (also known as Battle Sheep) is a board game where players compete to control territory on a hexagonal grid. The game is implemented as a web application using Ruby on Rails for the backend and a separate frontend repository.

### Key Features

- User authentication and session management
- Room-based multiplayer system
- Real-time game updates using WebSockets
- AI players
- Game state tracking and validation
- RESTful API for frontend integration

### Technology Stack

- **Backend**: Ruby on Rails
- **Database**: PostgreSQL
- **Real-time Communication**: Action Cable (WebSockets)
- **Caching and Pub/Sub**: Redis
- **Frontend**: Separate repository (https://github.com/side-project-at-SPT/split-front)

## How to Use This Documentation

Each diagram file focuses on a specific aspect of the system. You can navigate between them to understand different parts of the architecture:

- Start with the **System Architecture** for a high-level overview
- Explore the **Models and Relationships** to understand the data structure
- Review the **Game Flow** and **Game States** to understand the gameplay mechanics
- Check the **API Endpoints** and **Real-time Communication Channels** to understand how the frontend interacts with the backend

These diagrams are designed to help developers understand the system architecture and make it easier to maintain and extend the application.
